Function Show-List($title, $lines) {
    $offset = 0;
    Clear-Host
    do {    
        $selectedLines = $lines[$offset..10]
        Write-Host $title -ForegroundColor Green
        $selectedLines | ForEach-Object -Process {
            Write-Host $_
        }
        Write-Host "______________________________
j - down, k - up, q - quit"
        $key = $Host.UI.RawUI.ReadKey('IncludeKeyDown').Character;
        if ($key -eq 'j') {
            $offset = $offset + 1;
            Clear-Host
        }
        if ($key -eq 'k') {
            $offset = $offset - 1;
            Clear-Host
        }
        if ($offset -gt ($lines.Count - 10)) {
            $offset = $lines.Count - 10
        }
        if ($offset -lt 0) {
            $offset = 0
        }
        
    } while ($key -ne 'q')
    Clear-Host
}
