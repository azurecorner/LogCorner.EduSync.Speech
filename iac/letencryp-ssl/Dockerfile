FROM mcr.microsoft.com/powershell:7.1.3-ubuntu-20.04
RUN bash
RUN apt-get update
RUN apt-get install wget -y
RUN pwsh -c "&{Install-Module -Name Az -AllowClobber -Scope AllUsers -Force}"
RUN pwsh -c "&{ Install-Module Az.Accounts, Az.KeyVault, Az.Resources,  AzureRM.Profile, Az.Storage, Posh-ACME -Force }"
RUN wget https://azcopyvnext.azureedge.net/release20190301/azcopy_linux_amd64_10.0.8.tar.gz && tar xvzf ./azcopy_linux_amd64_10.0.8.tar.gz && rm ./azcopy_linux_amd64_10.0.8.tar.gz && cp ./azcopy_linux_amd64_10.0.8/azcopy ./ && rm -rf ./azcopy_linux_amd64_10.0.8 && ./azcopy --version
RUN chmod +x azcopy
RUN azcopy --version
RUN mkdir app
COPY . app/
WORKDIR /app
ENTRYPOINT ["pwsh","run.ps1"]