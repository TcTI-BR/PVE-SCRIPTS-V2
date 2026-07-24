@echo off
color 0B
title Gerador de Pacote - PVE SCRIPTS V2

echo ========================================================
echo       Gerador de Pacote Offline (main.tar.gz)
echo ========================================================
echo.

:: Verifica se a pasta functions e o main.sh existem no diretório atual
if not exist "main.sh" (
    echo [ERRO] O script main.sh nao foi encontrado!
    echo Execute este arquivo .bat na raiz do projeto.
    pause
    exit /b
)

echo [1] Removendo pacote antigo se existir...
if exist "main.tar.gz" del /f "main.tar.gz"

echo [2] Compactando os arquivos do projeto...
:: Usa o utilitario nativo do Windows 10/11 para criar o tar.gz
:: Empacota ESTRITAMENTE o arquivo main.sh e a pasta functions (necessarios para o update funcionar)
tar -czvf main.tar.gz main.sh functions

echo.
if exist "main.tar.gz" (
    echo ========================================================
    echo [SUCESSO] Arquivo main.tar.gz gerado com sucesso!
    echo ========================================================
) else (
    echo [ERRO] Falha ao gerar o pacote!
)

echo.
pause
