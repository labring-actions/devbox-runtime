sudo wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh && \
sudo chmod -R +x ./dotnet-install.sh && \
sudo ./dotnet-install.sh --version 9.0.100 -InstallDir /usr/share/dotnet/ && \
echo 'export PATH=$PATH:/usr/share/dotnet/' >> ~/.bashrc && \
source ~/.bashrc && \
sudo apt-get update && sudo apt-get install -y libicu-dev && \
dotnet add package ModelContextProtocol --prerelease && \
dotnet add package ModelContextProtocol.AspNetCore --prerelease && \
