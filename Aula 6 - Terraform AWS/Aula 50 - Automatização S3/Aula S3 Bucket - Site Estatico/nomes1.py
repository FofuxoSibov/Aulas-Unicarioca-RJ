lista_nomes = ["Ana", "Bruno", "Carla", "Diego", "Elisa", "Betti", "Monalisa"]
#for nome in lista_nomes:
#print (lista_nomes[3])

# for nome in lista_nomes:
#     if nome == "Diego":
#         print("Nome:", nome)
#         break
#     print("passou")

for nome in lista_nomes:
    if nome == "Elisa":
        print("Nome:", nome)
        continue
    print("passou")