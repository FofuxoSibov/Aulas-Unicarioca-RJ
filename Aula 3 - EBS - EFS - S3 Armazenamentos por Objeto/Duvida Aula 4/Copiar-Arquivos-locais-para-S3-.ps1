# Configurações
$sourcePath = "G:\Meu Drive\Aprenda na Nuvem\Cursos\AWS na Pratica - Unicarioca RJ"                  # Caminho da unidade D:
$bucketName = "meusitefofuxo"        # Nome do bucket S3
$largeFilesFolder = "arquivosgrandes" # Nome da pasta para arquivos maiores que 1GB

# Função para verificar tamanho do arquivo e enviar ao S3
function Upload-ToS3 {
    param (
        [string]$filePath
    )
    # Obtém informações do arquivo
    $fileInfo = Get-Item $filePath
    $fileSizeInBytes = $fileInfo.Length
    $fileKey = $fileInfo.FullName.Substring($sourcePath.Length) -replace '\\', '/'

    # Define o destino baseado no tamanho do arquivo
    if ($fileSizeInBytes -gt 1GB) {
        $s3Key = "$largeFilesFolder/$fileKey"
    } else {
        $s3Key = $fileKey
    }

    # Faz o upload do arquivo para o S3
    aws s3 cp $filePath "s3://$bucketName/$s3Key"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Arquivo '$filePath' enviado com sucesso para 's3://$bucketName/$s3Key'."
    } else {
        Write-Host "Erro ao enviar arquivo '$filePath'." -ForegroundColor Red
    }
}

# Percorre todos os arquivos no diretório de origem
Get-ChildItem -Path $sourcePath -Recurse -File | ForEach-Object {
    Upload-ToS3 -filePath $_.FullName
}
