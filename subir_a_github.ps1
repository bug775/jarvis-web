# Sube el webroot de JARVIS a GitHub Pages (rama gh-pages).
# Requisito previo: el repo PUBLICO "jarvis-web" de bug775 debe existir en github.com.
# Al primer push se abrira una ventana de GitHub para iniciar sesion; luego desactivar:
#   Settings > Pages > Source: "Deploy from a branch" > gh-pages / (root) > Save
#
# Cada publicacion reconstruye un commit raiz (orpan) de los archivos actuales:
# asi el historial de la rama no acumula los zips gigantes de versiones previas
# (GitHub rechaza archivos > 100 MB y repasar el historial entero es innecesario
# para un sitio estatico).

$ErrorActionPreference = "Continue"
Set-Location -LiteralPath $PSScriptRoot

if (-not (Test-Path -LiteralPath ".git")) {
    git init -b gh-pages
}

$TMP_BRANCH = "_jarvis_publish"
git branch -D $TMP_BRANCH 2>&1 | Out-Null
git checkout --orphan $TMP_BRANCH 2>&1 | Out-Null
if ($?) {
    # rama con historial: reconstruimos un solo commit raiz
    git add -A
    git -c user.name="JARVIS" -c user.email="jarvis@local" commit -m "web 24/7 de JARVIS" 2>&1 | Out-Null
    git branch -f gh-pages HEAD
    git checkout gh-pages 2>&1 | Out-Null
    git branch -D $TMP_BRANCH 2>&1 | Out-Null
} else {
    # repo recien creado sin commits: publicamos directo sobre gh-pages
    git add -A
    git -c user.name="JARVIS" -c user.email="jarvis@local" commit -m "web 24/7 de JARVIS" 2>&1 | Out-Null
    git branch -f gh-pages HEAD
    git checkout gh-pages 2>&1 | Out-Null
}

if (-not (git remote | Select-String -SimpleMatch "origin")) {
    git remote add origin https://github.com/bug775/jarvis-web.git
}
git push -f origin gh-pages
if ($LASTEXITCODE -ne 0) {
    "ERROR: fallo el push a gh-pages."
    exit 1
}
"OK: publicado en gh-pages. Ahora activa Pages en Settings > Pages (branch gh-pages, / root)."