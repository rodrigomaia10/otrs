#!/bin/bash

# Caminho onde os pacotes .opm estão
PACKAGE_DIR="/opt/znuny/Packages/"

# Lista dos pacotes obrigatórios (nomes base, sem versão e extensão)
required_packages=(
  "GeneralCatalog"
  "ITSMCore"
  "ITSMIncidentProblemManagement"
  "ITSMConfigurationManagement"
  "ITSMServiceLevelManagement"
  "ITSMChangeManagement"
  "ImportExport"
  "Core"
  "FAQ"
  "CustomerUserImportExport"
  "DynamicFieldFileSystem"
  "CustomTicketNumber"
  "FAQServicesWidget"
  "Survey"
  "NewSurveyLayout"
  "SurveyPlus"
  "InBox_CustomTicketNumber"
)

# Verifica se o diretório existe
if [ ! -d "$PACKAGE_DIR" ]; then
  echo "Erro: O diretório $PACKAGE_DIR não existe."
  exit 1
fi

install_or_upgrade() {
  local package_file="$1"
  echo "🔄 Tentando upgrade de: $(basename "$package_file")"
  
  upgrade_output=$(bin/znuny.Console.pl Admin::Package::Upgrade "$package_file" 2>&1)
  
  if echo "$upgrade_output" | grep -q "Package is not installed"; then
    echo "📦 Pacote não instalado. Instalando: $(basename "$package_file")"
    bin/znuny.Console.pl Admin::Package::Install "$package_file"
    if [ $? -ne 0 ]; then
      echo "❌ Erro ao instalar $(basename "$package_file")"
      exit 1
    fi
  elif echo "$upgrade_output" | grep -q "already installed"; then
    echo "✅ Pacote já está atualizado: $(basename "$package_file"). Ignorando."
  elif echo "$upgrade_output" | grep -qi "error"; then
    echo "❌ Erro durante o upgrade de $(basename "$package_file")"
    echo "$upgrade_output"
    exit 1
  else
    echo "✔️  Upgrade realizado com sucesso: $(basename "$package_file")"
  fi
}

echo "### Etapa 1: Instalando pacotes obrigatórios em ordem definida..."

for pkg_name in "${required_packages[@]}"; do
  search_name="${pkg_name//_/' '}"
  pkg_path=$(find "$PACKAGE_DIR" -maxdepth 1 -type f -iname "${search_name}-*.opm" | head -n 1)

  if [ -f "$pkg_path" ]; then
    install_or_upgrade "$pkg_path"
  else
    echo "⚠️  Pacote $pkg_name não encontrado no diretório."
  fi
done

echo "### Etapa 2: Instalando pacotes restantes..."

for pkg_path in "$PACKAGE_DIR"/*.opm; do
  pkg_filename=$(basename "$pkg_path")
  pkg_name_no_ext="${pkg_filename%.opm}"
  pkg_basename="${pkg_name_no_ext%-*}"
  pkg_basename="${pkg_basename// /_}"

  if printf '%s\n' "${required_packages[@]}" | grep -qx "$pkg_basename"; then
    continue
  fi

  install_or_upgrade "$pkg_path"
done

echo "✅ Todos os pacotes foram processados com sucesso."

