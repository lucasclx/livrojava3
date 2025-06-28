#!/bin/bash

# Script para criar estrutura de imagens e resolver erros 404

echo "=== Configurando Imagens para Livraria Online ==="
echo

# Definir diretórios
WEBAPP_DIR="src/main/webapp"
IMG_DIR="$WEBAPP_DIR/images"

# Criar diretório de imagens se não existir
echo "1. Criando diretório de imagens..."
mkdir -p "$IMG_DIR"
echo "   ✓ Diretório $IMG_DIR criado"

# Criar imagem SVG padrão
echo "2. Criando imagem padrão..."
cat > "$IMG_DIR/no-image.svg" << 'EOF'
<svg width="200" height="300" xmlns="http://www.w3.org/2000/svg">
  <!-- Fundo -->
  <rect width="200" height="300" fill="#f8f9fa" stroke="#dee2e6" stroke-width="2" rx="8"/>
  
  <!-- Ícone de livro -->
  <g transform="translate(100, 120)">
    <rect x="-25" y="-30" width="50" height="40" fill="#6c757d" rx="2"/>
    <rect x="-20" y="-25" width="40" height="30" fill="#adb5bd" rx="1"/>
    <line x1="-15" y1="-20" x2="15" y2="-20" stroke="#6c757d" stroke-width="1"/>
    <line x1="-15" y1="-15" x2="15" y2="-15" stroke="#6c757d" stroke-width="1"/>
    <line x1="-15" y1="-10" x2="10" y2="-10" stroke="#6c757d" stroke-width="1"/>
  </g>
  
  <!-- Texto -->
  <text x="100" y="200" text-anchor="middle" font-family="Arial, sans-serif" font-size="14" fill="#6c757d" font-weight="500">
    Sem Imagem
  </text>
  <text x="100" y="220" text-anchor="middle" font-family="Arial, sans-serif" font-size="12" fill="#adb5bd">
    Disponível
  </text>
</svg>
EOF
echo "   ✓ Imagem padrão no-image.svg criada"

# Criar algumas imagens de exemplo usando SVG (simulando capas de livros)
echo "3. Criando imagens de exemplo..."

# Dom Casmurro
cat > "$IMG_DIR/dom-casmurro.svg" << 'EOF'
<svg width="200" height="300" xmlns="http://www.w3.org/2000/svg">
  <rect width="200" height="300" fill="#8B4513" rx="8"/>
  <rect x="10" y="10" width="180" height="280" fill="#D2691E" rx="4"/>
  <text x="100" y="50" text-anchor="middle" font-family="serif" font-size="18" fill="#FFF" font-weight="bold">DOM</text>
  <text x="100" y="80" text-anchor="middle" font-family="serif" font-size="18" fill="#FFF" font-weight="bold">CASMURRO</text>
  <text x="100" y="250" text-anchor="middle" font-family="serif" font-size="12" fill="#FFF">Machado de Assis</text>
</svg>
EOF

# 1984
cat > "$IMG_DIR/1984.svg" << 'EOF'
<svg width="200" height="300" xmlns="http://www.w3.org/2000/svg">
  <rect width="200" height="300" fill="#000" rx="8"/>
  <rect x="10" y="10" width="180" height="280" fill="#333" rx="4"/>
  <text x="100" y="100" text-anchor="middle" font-family="Arial" font-size="48" fill="#FF0000" font-weight="bold">1984</text>
  <text x="100" y="250" text-anchor="middle" font-family="Arial" font-size="14" fill="#FFF">George Orwell</text>
</svg>
EOF

# Clean Code
cat > "$IMG_DIR/clean-code.svg" << 'EOF'
<svg width="200" height="300" xmlns="http://www.w3.org/2000/svg">
  <rect width="200" height="300" fill="#0066CC" rx="8"/>
  <rect x="10" y="10" width="180" height="280" fill="#003d7a" rx="4"/>
  <text x="100" y="60" text-anchor="middle" font-family="Arial" font-size="16" fill="#FFF" font-weight="bold">CLEAN</text>
  <text x="100" y="90" text-anchor="middle" font-family="Arial" font-size="16" fill="#FFF" font-weight="bold">CODE</text>
  <text x="100" y="250" text-anchor="middle" font-family="Arial" font-size="12" fill="#FFF">Robert C. Martin</text>
</svg>
EOF

# Pequeno Príncipe
cat > "$IMG_DIR/pequeno-principe.svg" << 'EOF'
<svg width="200" height="300" xmlns="http://www.w3.org/2000/svg">
  <rect width="200" height="300" fill="#FFD700" rx="8"/>
  <rect x="10" y="10" width="180" height="280" fill="#FFA500" rx="4"/>
  <circle cx="100" cy="100" r="30" fill="#87CEEB"/>
  <circle cx="100" cy="100" r="20" fill="#FFE4B5"/>
  <text x="100" y="200" text-anchor="middle" font-family="serif" font-size="14" fill="#333" font-weight="bold">O PEQUENO</text>
  <text x="100" y="220" text-anchor="middle" font-family="serif" font-size="14" fill="#333" font-weight="bold">PRÍNCIPE</text>
  <text x="100" y="260" text-anchor="middle" font-family="serif" font-size="10" fill="#333">Saint-Exupéry</text>
</svg>
EOF

echo "   ✓ Imagens de exemplo criadas"

# Atualizar schema.sql para usar as novas imagens
echo "4. Criando script SQL atualizado..."
cat > "update_images.sql" << 'EOF'
-- Script para atualizar imagens dos livros
UPDATE livros SET imagem = 'images/dom-casmurro.svg' WHERE titulo = 'Dom Casmurro';
UPDATE livros SET imagem = 'images/1984.svg' WHERE titulo = '1984';
UPDATE livros SET imagem = 'images/clean-code.svg' WHERE titulo = 'Clean Code';
UPDATE livros SET imagem = 'images/pequeno-principe.svg' WHERE titulo = 'O Pequeno Príncipe';

-- Para todos os outros livros sem imagem, usar a imagem padrão
UPDATE livros SET imagem = 'images/no-image.svg' 
WHERE imagem IS NULL OR imagem = '' OR imagem LIKE '%/no-image.jpg%';
EOF
echo "   ✓ Script update_images.sql criado"

# Verificar se a aplicação está rodando e tentar aplicar as mudanças
echo "5. Verificando aplicação..."
if curl -s "http://localhost:8080/livrojava2.0/" > /dev/null 2>&1; then
    echo "   ✓ Aplicação está rodando em http://localhost:8080/livrojava2.0/"
    echo "   → Recompile e redeploy para aplicar as mudanças"
else
    echo "   ⚠️  Aplicação não está rodando ou não está acessível"
fi

# Criar um arquivo .htaccess para servir SVGs corretamente (se usando Apache)
echo "6. Configurando tipos MIME..."
cat > "$WEBAPP_DIR/.htaccess" << 'EOF'
# Configurar tipo MIME para SVG
AddType image/svg+xml .svg

# Cache para imagens
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType image/svg+xml "access plus 1 month"
    ExpiresByType image/png "access plus 1 month"
    ExpiresByType image/jpg "access plus 1 month"
    ExpiresByType image/jpeg "access plus 1 month"
</IfModule>
EOF
echo "   ✓ Configuração .htaccess criada"

echo
echo "=== INSTRUÇÕES PARA APLICAR AS MUDANÇAS ==="
echo
echo "1. Se usando banco de dados MySQL:"
echo "   mysql -u root -p livraria < update_images.sql"
echo
echo "2. Recompilar e redeploy:"
echo "   mvn clean compile war:war"
echo "   cp target/*.war \$TOMCAT_HOME/webapps/"
echo
echo "3. Reiniciar o Tomcat se necessário"
echo
echo "4. Testar no navegador:"
echo "   http://localhost:8080/livrojava2.0/"
echo
echo "=== RESULTADO ESPERADO ==="
echo "- ✅ Não mais erros 404 para imagens"
echo "- ✅ Livros com imagens padrão SVG funcionais"
echo "- ✅ Interface mais limpa e profissional"
echo
echo "Estrutura criada com sucesso!"

# Listar arquivos criados
echo
echo "Arquivos criados:"
find "$IMG_DIR" -type f -name "*.svg" | while read file; do
    echo "   ✓ $file"
done
echo "   ✓ update_images.sql"
echo "   ✓ $WEBAPP_DIR/.htaccess"
