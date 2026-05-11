Add-Type -AssemblyName System.Drawing

$width = 1024
$height = 1024
$bitmap = New-Object System.Drawing.Bitmap($width, $height)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)

# Anti-aliasing
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# Background color (Deep Purple - #5B6CFF)
$bgColor = [System.Drawing.ColorTranslator]::FromHtml("#5B6CFF")
$graphics.Clear($bgColor)

# Text Color (White)
$textColor = [System.Drawing.ColorTranslator]::FromHtml("#FFFFFF")
$brush = New-Object System.Drawing.SolidBrush($textColor)

# Font
try {
    $fontFamily = New-Object System.Drawing.FontFamily("Segoe UI")
} catch {
    $fontFamily = New-Object System.Drawing.FontFamily("Arial")
}
$fontStyle = [System.Drawing.FontStyle]::Bold
$fontSize = 350
$font = New-Object System.Drawing.Font($fontFamily, $fontSize, $fontStyle)

$text = "LK"

# Measure text
$stringFormat = New-Object System.Drawing.StringFormat
$stringFormat.Alignment = [System.Drawing.StringAlignment]::Center
$stringFormat.LineAlignment = [System.Drawing.StringAlignment]::Center

# Draw text centered
$rect = New-Object System.Drawing.RectangleF(0, 0, $width, $height)
$graphics.DrawString($text, $font, $brush, $rect, $stringFormat)

# Clean up
$font.Dispose()
$brush.Dispose()
$graphics.Dispose()

# Save
$outPath = "d:\linkkart\mobile-app\assets\icons\app_icon.png"
$fgPath = "d:\linkkart\mobile-app\assets\icons\app_icon_foreground.png"

$bitmap.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bitmap.Save($fgPath, [System.Drawing.Imaging.ImageFormat]::Png)

$bitmap.Dispose()

Write-Host "Icons generated successfully!"
