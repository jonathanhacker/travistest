echo "*** Installing apt Dependencies ***"
apt-get update
packagelist=(
	python3-pip #python package management
	ffmpeg #audio conversion
	atomicparsley #thumbnail embedding
	nginx #webserver
	pulseaudio #audio configuration
	pulseaudio-module-bluetooth # bluetooth playback
	libglib2.0-dev libgirepository1.0-dev libcairo2-dev # PyGObject dependencies
	gstreamer1.0-plugins-bad # m4a playback
	postgresql libpq-dev #database
	redis-server #channel layer
	autossh #remote connection
	curl #key fetching
)
apt-get install -y ${packagelist[@]} || exit 1

# force system wide reinstall even if packages are present for the user by using sudo -H
sudo -H pip3 install -r requirements.txt || exit 1

echo "*** Installing yarn ***"
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
apt-get update
apt-get install -y yarn

if [ ! -z "$HOTSPOT" ]; then
	apt-get install -y dnsmasq hostapd #wifi access point
fi

if [ ! -z "$SCREEN_VISUALIZATION" ]; then
	echo "*** Installing pi3d and dependencies ***"
	sudo -H pip3 install pi3d # OpenGL Framework
	packagelist=(
		python3-numpy # heavier computation; pip installs too new version
		python3-scipy # gaussian filtering
		python3-pil # image texture loading
		mesa-utils libgles2-mesa-dev # graphics drivers
		xorg # X is needed for displaying
	)
	apt-get install -y ${packagelist[@]} || exit 1
fi

if [[ ( ! -z "$LED_VISUALIZATION" || ! -z "$SCREEN_VISUALIZATION" ) ]] && ! type cava > /dev/null 2>&1; then
	echo "*** Installing cava ***"
	cd /opt
	git clone https://github.com/karlstav/cava
	cd cava
	apt-get install -y libfftw3-dev libasound2-dev libncursesw5-dev libpulse-dev libtool m4 automake libtool
	./autogen.sh
	./configure
	make
	make install
	cd $SERVER_ROOT
fi

echo "*** Installing System Scripts ***"
scripts/install_system_scripts.sh
