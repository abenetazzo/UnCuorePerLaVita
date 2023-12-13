#include <cstdio>
#include <sstream>
#include <limits>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
#include <vector>
#include <libpq-fe.h>

using namespace std;

class QSelect{
  public:
    vector<string> headers;
    vector<vector<string>> data;
    QSelect();
    friend ostream& operator<<(ostream&, const QSelect&);
};
QSelect::QSelect(): headers(0), data(0) {}
ostream& operator<<(ostream& os, const vector<string>& v){
  for(auto& i : v){ os << left << setw(23) << i << " | "; };
  return os;
}
ostream& operator<<(ostream& os, const QSelect& q){
  cout << q.headers << endl << endl;
  for(auto& v : q.data){
    cout << v << endl;
  }
  return os;
}

PGconn * const get_conn(){
  static const string& conninfo = R"(
    host=147.162.84.210
    port=5432
    user=ascantam
    password=MgUdtG2LV7_W
    dbname=aa-ospedale-trapianti-progetto
  )";
  static PGconn * conn = PQconnectdb(conninfo.c_str());
  if (PQstatus(conn) != CONNECTION_OK) {
    cout << "Errore di connessione: " << PQerrorMessage(conn) << endl;
    PQfinish(conn);
    exit(1);
  }
  return conn;
}

QSelect select_from(const string& qstr,const vector<string>& args = {}) {
  vector<const char *> params;
  for(const string& a : args){ params.push_back(a.c_str()); }

  PGresult * stmt = PQprepare(get_conn(),qstr.c_str(),qstr.c_str(),args.size(),NULL);
  if (PQresultStatus(stmt) != 1 && PQresultStatus(stmt) != 7) { 
    cerr << endl << "==============================================" << endl;
    cerr << "CODICE: <" <<PQresultStatus(stmt) << ">" << endl;
    cerr << "RISULTATI INCONSISTENTI IN PREPARAZIONE!" << endl;
    cerr << PQerrorMessage(get_conn()) << endl;
    cerr << "==============================================" << endl ;
    PQclear(stmt); 
    PQfinish(get_conn());
    exit(1);
  }
  PGresult * res = PQexecPrepared(get_conn(),qstr.c_str(),args.size(),params.data(),NULL,0,0);
	if ( PQresultStatus(res) != PGRES_TUPLES_OK ){
		cerr << endl << "==============================================" << endl;
    cerr << "RISULTATI INCONSISTENTI!" << endl;
    cerr << "CODICE: <" <<PQresultStatus(res) << ">" << endl;
    cerr << PQerrorMessage(get_conn()) << endl;
    cerr << "==============================================" << endl ;
		PQclear ( res ) ;
    PQfinish(get_conn());
    exit(1);
	}

	int tuple = PQntuples(res);
	int campi = PQnfields(res);
  QSelect q;
  for(int i = 0; i < tuple; i++){
    q.data.push_back({});
    for(int j = 0; j < campi; j++){
      q.data.at(i).push_back(PQgetvalue(res,i,j));
    }
  }
  vector<string> q_headers(campi);
  for(int i = 0; i < campi; i++){
    q.headers.push_back(PQfname(res,i));
  }
  return q;
}

const vector<string>& get_record_from_qs(const QSelect& qs){
  int i;
  char p;
  while(true){
    if(cin.fail()){
      cin.clear();
      cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
      cout << "Input invalido" << endl;
      continue;
    }

    p = 0;
    cout << endl;
    cout << "Comandi:" << endl;
    cout << "\ts <I>        // per selezionare il record." << endl;
    cout << "\tp <I> <J>    // per stampare i record con indice compreso tra I e J." << endl;
    cout << "Esempi:" << endl;
    cout << "\t's 0' seleziona l'ultimo elemento." << endl;
    cout << "\t'p 0 " << qs.data.size()-1 << "' stampa tutta la lista." << endl;
    cout << "Input: ";
    cin >> p;
    cout << endl;

    if(p == 's'){
      cin >> i;
      if(cin.fail()){ continue; }
      if(i < 0 || i > qs.data.size()){
        cout << "Indice invalido"<< endl;
        continue;
      };
      break;
    }else if(p=='p'){
      int i,j;
      cin >> i >> j;
      if(cin.fail()){ continue; }
      cout << right << setw(8) << "Indice" << " | " << left << qs.headers << endl;
      for(int k = (i >= 0 ? i:0); k <= j && k < qs.data.size(); k++){
        cout << right << setw(8) << k << " | " << left << qs.data.at(k) << endl;
      }
      cout << endl;
    }
  }
  return qs.data.at(i);
}

int main (int argc, char **argv) {
  get_conn();
  vector<vector<string>> queries = {
    {
      "Trapianti con ricevente e donatore aventi gruppi sanguigni non compatibili (VINCOLO NON ESPRIMIBILE IN SQL, DOVREBBE SEMPRE ESSERE VUOTA)",
      R"(SELECT errori.ricevente, riceventi.gruppo_sanguigno AS gruppo_ricevente, errori.donatore, donatori.gruppo_sanguigno AS gruppo_donatore
      FROM (SELECT trapianti.ricevente, trapianti.donatore
       FROM trapianti, pazienti AS riceventi, pazienti AS donatori
       EXCEPT (SELECT donatori.donatore, riceventi.ricevente
        FROM (SELECT pazienti.codice_fiscale AS donatore, pazienti.gruppo_sanguigno AS gruppo_donatore
         FROM pazienti) AS donatori, compatibilita,
         (SELECT pazienti.codice_fiscale AS ricevente, pazienti.gruppo_sanguigno AS gruppo_ricevente
         FROM pazienti) AS riceventi
        WHERE donatori.gruppo_donatore = compatibilita.gruppo_donatore
        AND riceventi.gruppo_ricevente = compatibilita.gruppo_ricevente)) AS errori, pazienti AS riceventi, pazienti AS donatori
      WHERE errori.ricevente = riceventi.codice_fiscale
      AND errori.donatore = donatori.codice_fiscale;)"
    },
    {
      "Costo medio dello staff medico necessario per il trapianto di ciascun organo",
      R"(SELECT organi.nome AS organo, AVG(equipe.costo_equipe) AS costo_medio_equipe
      FROM (SELECT equipe_chirurgica.trapianto, SUM(personale_medico.compenso) AS costo_equipe
        FROM equipe_chirurgica, personale_medico
        WHERE personale_medico.codice_fiscale = equipe_chirurgica.membro_equipe
        GROUP BY (trapianto)) AS equipe, trapianti, organi
      WHERE trapianti.id = equipe.trapianto
      AND trapianti.organo = organi.id
      GROUP BY organi.nome;)"
    },
    {
      "(P) Costo a carico del ricevente (non coperto dall'assicurazione) per un trapianto",
      R"(SELECT CASE
          WHEN costo_trapianto.massimale IS NULL
          THEN costo_trapianto.costo_trapianto
          WHEN costo_trapianto.costo_trapianto > costo_trapianto.massimale
          THEN costo_trapianto.costo_trapianto - costo_trapianto.massimale
          ELSE 0
        END
        AS costo_paziente
      FROM (SELECT costo_trapianto.paziente, costo_trapianto.costo_trapianto, assicurazioni.massimale
        FROM (SELECT costo_staff.paziente, organi.costo + costo_staff.costo_equipe AS costo_trapianto
          FROM (SELECT compenso_equipe.paziente, compenso_equipe.organo, SUM(compenso) AS costo_equipe
            FROM (SELECT equipe.paziente, equipe.membro_equipe, personale_medico.compenso, equipe.organo
              FROM (SELECT trapianti.ricevente AS paziente, equipe_chirurgica.membro_equipe, trapianti.organo
                FROM equipe_chirurgica
                JOIN trapianti
                ON equipe_chirurgica.trapianto = trapianti.id
                WHERE trapianti.id = $1::int)
                AS equipe, personale_medico
              WHERE equipe.membro_equipe = personale_medico.codice_fiscale)
              AS compenso_equipe
            GROUP BY (compenso_equipe.paziente, compenso_equipe.organo)) AS costo_staff, organi
          WHERE organi.id = costo_staff.organo) AS costo_trapianto
        LEFT JOIN assicurazioni
        ON costo_trapianto.paziente = assicurazioni.cliente) AS costo_trapianto;)"
    },
    {
      "(P) Trapianti di un paziente",
      R"(SELECT organi.nome AS organo, trapianti_paziente.data, anagrafiche.cognome AS cognome_donatore, anagrafiche.nome AS nome_donatore
      FROM (SELECT trapianti.organo, trapianti.data, trapianti.donatore
        FROM trapianti
        WHERE ricevente = $1::varchar ) AS trapianti_paziente, organi, anagrafiche
      WHERE organi.id = trapianti_paziente.organo
      AND anagrafiche.codice_fiscale = trapianti_paziente.donatore;)"
    },
    {
      "Trapianti con membri del personale medico tirocinante e senza membri del personale medico non tirocinante (VINCOLO NON ESPRIMIBILE IN SQL, DOVREBBE SEMPRE ESSERE VUOTA)",
      R"(SELECT DISTINCT trapianti.id AS id_trapianto, personale_medico.mansione
      FROM trapianti, personale_medico, equipe_chirurgica
      WHERE trapianti.id = equipe_chirurgica.trapianto
      AND equipe_chirurgica.membro_equipe = personale_medico.codice_fiscale
      EXCEPT (SELECT DISTINCT trapianti_equipe1.id AS id_trapianto, trapianti_equipe1.mansione
          FROM (SELECT trapianti.id, personale_medico.mansione, personale_medico.compenso
            FROM trapianti, personale_medico, equipe_chirurgica
            WHERE trapianti.id = equipe_chirurgica.trapianto
            AND personale_medico.codice_fiscale = equipe_chirurgica.membro_equipe) AS trapianti_equipe1
          JOIN (SELECT trapianti.id, personale_medico.mansione, personale_medico.compenso
            FROM trapianti, personale_medico, equipe_chirurgica
            WHERE trapianti.id = equipe_chirurgica.trapianto
            AND personale_medico.codice_fiscale = equipe_chirurgica.membro_equipe) AS trapianti_equipe2
          ON trapianti_equipe1.id = trapianti_equipe2.id
          AND trapianti_equipe1.mansione = trapianti_equipe2.mansione
          AND ((trapianti_equipe1.compenso = 0 AND trapianti_equipe2.compenso <> 0)
             OR trapianti_equipe1.compenso <> 0)
        ORDER BY id_trapianto)
      ORDER BY id_trapianto)"
    },
    {
      "Per ogni organo disponibile per essere donato viene dato il potenziale ricevente in lista d'attesa con priorità più alta e in lista da più tempo",
      R"(SELECT abbinamenti.ricevente, abbinamenti.gruppo_ricevente, organi.nome AS organo, abbinamenti.priorita, abbinamenti.data_ora,
            abbinamenti.donatore, abbinamenti.gruppo_donatore
          FROM (SELECT richieste.ricevente, richieste.gruppo_ricevente, richieste.organo_richiesto, richieste.priorita, richieste.data_ora,
              disponibilita.donatore, disponibilita.gruppo_donatore
            FROM (SELECT lista_organi.paziente AS ricevente, pazienti.gruppo_sanguigno AS gruppo_ricevente, lista_organi.organo AS organo_richiesto,
                lista_organi.priorita, lista_organi.data_ora
              FROM lista_organi, pazienti
              WHERE priorita IS NOT NULL
              AND lista_organi.paziente = pazienti.codice_fiscale
              ORDER BY lista_organi.priorita DESC, lista_organi.data_ora ASC) AS richieste
            JOIN compatibilita
            ON richieste.gruppo_ricevente = compatibilita.gruppo_ricevente
            JOIN (SELECT lista_organi.paziente AS donatore, pazienti.gruppo_sanguigno AS gruppo_donatore, lista_organi.organo AS organo_disponibile
              FROM lista_organi, pazienti
              WHERE priorita IS NULL
              AND lista_organi.paziente = pazienti.codice_fiscale) AS disponibilita
            ON disponibilita.gruppo_donatore = compatibilita.gruppo_donatore
            WHERE richieste.organo_richiesto = disponibilita.organo_disponibile) AS abbinamenti, organi
          WHERE abbinamenti.organo_richiesto = organi.id
          ORDER BY organo ASC, priorita DESC, data_ora ASC, ricevente ASC;)"
    },
    {
      "(P) Pazienti che hanno subito più di un trapianto durante un anno specifico",
      R"(SELECT anagrafiche.nome, anagrafiche.cognome, COUNT(trapianti.ricevente) AS n_trapianti
      FROM anagrafiche, trapianti
      WHERE anagrafiche.codice_fiscale = trapianti.ricevente
      AND EXTRACT(YEAR FROM trapianti.data) = $1::int 
      GROUP BY anagrafiche.nome, anagrafiche.cognome
      HAVING COUNT(trapianti.ricevente) > 1;)"
    }
  };

  int i = 0;
  string line = "";
  while(true){
    cout << endl;
    cout << right << setw(6) << "-1" << ") " << left << setw(80) << "Esci" << endl;
    for(int j=0; j < queries.size(); j++){
      cout << right << setw(6) <<  j << ") " << left << setw(80) << queries.at(j).at(0) << endl;
    }
    cout << endl;
    cout << "Inserisci il valore: ";
    cin >> i;

    if(cin.eof()){
      cout << endl << endl; 
      break;
    } else if(cin.fail()){
      cin.clear();
      cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
      cout << "Input invalido" << endl;
      continue;
    } else if(i==-1){
      break;
    } else if( i == 0 || i == 1 || i == 4 || i == 5 ){
      cout << select_from(queries.at(i).at(1)) << endl;
    } else if( i == 2 ){
      static const QSelect trapianti = select_from("SELECT * FROM trapianti;");
      line = get_record_from_qs(trapianti).at(0);
      cout << select_from(queries.at(i).at(1),{ line });
    } else if( i == 3 ){
      static const QSelect pazienti = select_from("SELECT * FROM pazienti;");
      line = get_record_from_qs(pazienti).at(0);
      cout << select_from(queries.at(i).at(1),{ line });
    } else if( i == 6 ){
      static const QSelect anni_trapianti = select_from("SELECT DISTINCT EXTRACT(YEAR FROM trapianti.data) from trapianti;");
      line = get_record_from_qs(anni_trapianti).at(0);
      cout << select_from(queries.at(i).at(1),{ line });
    }
  }

  PQfinish(get_conn());
  return 0;
}
