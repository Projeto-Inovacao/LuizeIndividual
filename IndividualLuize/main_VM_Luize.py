import psutil
import threading
import time
import keyboard
import socket
import pymssql #Conectando com o Banco remoto
import mysql.connector# Banco Local
from datetime import datetime
from cred import usr, pswd

event = threading.Event()
print(event)

id_maquina = None
mydb = None

def stop():
    event.set()
    print("\nFinalizando monitoramento")
    print(event)

keyboard.add_hotkey("esc", stop)

while not event.is_set():
    try:
        if mydb is None or not mydb.is_connected():
            mydb = mysql.connector.connect(host='localhost', user=usr, password=pswd, database='nocline')

        cpu = psutil.cpu_times()
        processador = psutil.cpu_percent(interval=1)
        memoria = psutil.virtual_memory()
        hostname = socket.gethostname()

        # CPU
        cpu_percentual = processador
        print("Verificando condições de alerta CPU")
        print("Valor atual de cpu_percentual:", cpu_percentual)
        if cpu_percentual > 0 and cpu_percentual < 4:
            print("Condição de alerta na linha CPU capturada (Risco)")
        elif cpu_percentual > 5:
            print("Condição de alerta CPU atendida (Perigo)")
        else:
            print("Nenhuma condição de alerta CPU atendida")

        # Memória
        memoria_disponivel = memoria.available
        memoria_total = memoria.total
        conta_memoria_disponivel = (memoria_disponivel / memoria_total) * 100
        conta_memoria_usada = 100 - conta_memoria_disponivel
        print("Verificando condições de alerta RAM")
        print("Valor atual de memoria_usada:", round(conta_memoria_usada, 2))
        if round(conta_memoria_usada, 2) > 80 and round(conta_memoria_usada, 2) < 90:
            print("Condição de alerta na linha RAM capturada (Risco)")
        elif round(conta_memoria_usada, 2) > 90:
            print("Condição de alerta RAM atendida (Perigo)")
        else:
            print("Nenhuma condição de alerta RAM atendida")

        sql_query = "SELECT id_maquina, fk_empresaM FROM maquina WHERE hostname = %s;"
        mycursor = mydb.cursor()
        mycursor.execute(sql_query, (hostname,))

        result = mycursor.fetchone()

        if result:
            id_maquina, fk_empresaM = result

            # Conexão com o servidor remoto!!!
            try:
                mydb_server = pymssql.connect(server='52.22.58.174', database='nocline', user='sa', password='urubu100')

                try:
                    mycursor_server = mydb_server.cursor()
                    sql_query_server = "SELECT id_maquina, fk_empresaM FROM maquina WHERE hostname = %s;"
                    mycursor_server.execute(sql_query_server, (hostname,))
                    result = mycursor_server.fetchone()

                    if result:
                        id_maquina, fk_empresaM = result
                        data_hora_local = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                        sql_query = """
                                INSERT INTO monitoramento (dado_coletado, data_hora, descricao, fk_componentes_monitoramento, fk_maquina_monitoramento, fk_empresa_monitoramento, fk_unidade_medida)
                                VALUES (%s, %s, 'uso de cpu py', (SELECT id_componente from componente WHERE nome_componente = 'CPU' and fk_maquina_componente = %s), %s, %s, (SELECT id_unidade FROM unidade_medida WHERE representacao = %s)),
                                    (%s, %s, 'memoria disponivel', (SELECT id_componente from componente WHERE nome_componente = 'RAM' and fk_maquina_componente = %s), %s, %s, (SELECT id_unidade FROM unidade_medida WHERE representacao = %s)),
                                    (%s, %s, 'memoria total', (SELECT id_componente from componente WHERE nome_componente = 'RAM' and fk_maquina_componente = %s), %s, %s, (SELECT id_unidade FROM unidade_medida WHERE representacao = %s));
                            """
                        val = (cpu_percentual, data_hora_local, id_maquina, id_maquina, fk_empresaM, '%',
                                memoria_disponivel, data_hora_local, id_maquina, id_maquina, fk_empresaM, 'B',
                                memoria_total, data_hora_local, id_maquina, id_maquina, fk_empresaM, 'B')
                        mycursor_server.execute(sql_query, val)
                        mydb_server.commit()
                        print(mycursor_server.rowcount, "registros inseridos no servidor remoto")
                        print("\r\n")

                except mysql.connector.Error as e:
                    print("Erro ao conectar com o servidor MySQLServer:", e)

                finally:
                        mycursor_server.close()
                        mydb_server.close()

            except pymssql.OperationalError as e:
