echo -e "\nInstalando bibliotecas"
if ! make install; then
    echo -e "Falha ao instalar shards\n"
    exit 1;
fi

echo -e "\nConectando ao Postgres e criando banco de dados"
if ! make sam db:create; then
    echo -e "Falha de conexão ou ao criar banco de dados\n"
    exit 1;
fi

echo -e "\nCriando tabela"
if ! make sam db:migrate; then
    echo -e "Falha ao criar tabela no banco de dados\n"
    exit 1;
fi

echo -e "\nSubindo aplicação"
if ! make server; then
    echo -e "Falha ao subir aplicação\n"
    exit 1;
fi