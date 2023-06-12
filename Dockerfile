FROM fedora:36

WORKDIR /usr/src/app

ENV PORT 8080
ENV HOST 0.0.0.0

ENV DOTNET_NOLOGO=1
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

RUN dnf -y install --setopt=install_weak_deps=False \
      bash bzip2 curl file findutils git make nano patch pkgconfig python3-pip unzip which xz \
      dotnet-sdk-6.0 && \
    pip install scons==4.4.0

ENV GODOT_SDK_LINUX_X86_64=/root/x86_64-godot-linux-gnu_sdk-buildroot
ENV GODOT_SDK_LINUX_X86=/root/i686-godot-linux-gnu_sdk-buildroot
ENV GODOT_SDK_LINUX_ARMHF=/root/arm-godot-linux-gnueabihf_sdk-buildroot
ENV BASE_PATH=${PATH}

#RUN dnf -y install --setopt=install_weak_deps=False \
#      libxcrypt-compat yasm && \
    # curl -LO https://github.com/godotengine/godot/releases/download/4.0.2-stable/godot-4.0.2-stable.tar.xz && \
    # tar xf godot-4.0.2-stable.tar.xz && \
    # rm -f godot-4.0.2-stable.tar.xz && \
    # cd godot-4.0.2-stable && \
    # rm -f bin/{aclocal*,auto*,libtool*,m4}

RUN dnf -y install --setopt=install_weak_deps=False \
     libxcrypt-compat yasm && \
     curl -LO https://github.com/godotengine/godot/releases/download/4.0.2-stable/Godot_v4.0.2-stable_linux.x86_64.zip && \
     unzip Godot_v4.0.2-stable_linux.x86_64.zip && \
     rm -f Godot_v4.0.2-stable_linux.x86_64.zip 
    
RUN ls -lha

COPY . ./app
CMD [ "/root/Godot_v4.0.2-stable_linux.x86_64", "--display-driver", "headless", "--path", "/root/app" ]
