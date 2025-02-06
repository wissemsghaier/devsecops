# #!/bin/bash

# set -e  # Stoppe le script en cas d'erreur

# #Add the trivy-repo
# sudo apt-get update
# sudo apt-get -y install wget apt-transport-https gnupg lsb-release
# wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
# echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list

# #Update Repo and Install trivy
# sudo apt-get update
# sudo apt-get install trivy -y



# dockerImageName="wissem200/devsecops:v1.0.0"
# echo $dockerImageName


# # Lancer le scan Trivy et générer un rapport JSON
# trivy image -f json -o trivy-report.json $dockerImageName



# docker run --rm -v /tmp/.cache:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 0 --severity HIGH --light $dockerImageName
# docker run --rm -v /tmp/.cache:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL --light $dockerImageName

# # Trivy scan result processing
#     exit_code=$?
#     echo "Exit Code : $exit_code"

#     # Check scan results
#     if [[ "${exit_code}" == 1 ]]; then
#         echo "Image scanning failed. Vulnerabilities found"
#         exit 1;
#     else
#         echo "Image scanning passed. No CRITICAL vulnerabilities found"
#     fi;




#!/bin/bash

set -e  # Stoppe le script en cas d'erreur

# # Ajouter le dépôt Trivy
# sudo apt-get update
# sudo apt-get -y install wget apt-transport-https gnupg lsb-release

# wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo gpg --dearmor -o /usr/share/keyrings/trivy-archive-keyring.gpg
# echo "deb [signed-by=/usr/share/keyrings/trivy-archive-keyring.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list

# # Mise à jour et installation de Trivy
# sudo apt-get update
# sudo apt-get install -y trivy

# Définition du nom de l'image Docker
dockerImageName="wissem200/devsecops:v1.0.0"
echo "Scanning image: $dockerImageName"

# Lancer le scan Trivy et générer un rapport JSON
trivy image -f json -o trivy-report.json "$dockerImageName"

# Exécuter Trivy avec des règles strictes (échec si vulnérabilités HIGH ou CRITICAL trouvées)
docker run --rm -v /tmp/.cache:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 0 --severity HIGH --light "$dockerImageName"
docker run --rm -v /tmp/.cache:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL --light "$dockerImageName"

# Vérifier le code de sortie de Trivy
exit_code=$?
echo "Exit Code : $exit_code"

if [[ "$exit_code" -ne 1 ]]; then
    echo "❌ Échec : Des vulnérabilités HIGH ou CRITICAL ont été trouvées dans l'image Docker."
    exit 1
else
    echo "✅ Succès : Aucune vulnérabilité HIGH ou CRITICAL détectée."
fi
