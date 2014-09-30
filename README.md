Apple2BuildPipeline
===================

A build pipeline for making Apple \]\[ software on OS X.

This project was built based on the one created by [Quinn Dunki](http://quinndunki.com/blondihacks/?p=1904) but it has been expanded to add the following features:

   * Attempts to hide all of the infrastructure which you don't need to modify in a make directory.
   * Supports linking together multiple C and assembly files.  To add a new file to the project, just create a new *.c or *.s file in the project directory.
   * If you change a header file, the right source files will rebuild automatically.  Header file dependencies are generated during the build.
   * Supports all cc65 Apple configurations.  So, if you want to target enhanced Apple //e's running DOS 3.3, knock yourself out.  Just set the configuration you want in the Makefile and the build will do the right thing to create a disk image for that configuration.
   * On Mac OS X, Virtual \]\[ will start when you build and the emulator with execute your program.  This works for all supported cc65 Apple configurations.  Also, it uses a machine configuration which is stored in the make directory in your project.  That way, you can modify the machine configuration to be exactly the config you want to test under.
   * The Mac OS X deliverable is now an installer which will create an Xcode project template.  So, to start a new Apple \]\[ project in Xcode, select File->New->Project.  Among the iOS and OS X project templates, you will find the "Apple \]\[ Project" option.  Select that and you will have a new Apple \]\[ project ready to go.

In order to use this infrastructure from Mac OS X, follow these instructions:
   1. Install Xcode from Apple.  Xcode is generally the most popular app in the Mac App Store in the "Developer Tools" category.
   2. [Download cc65 v2.13.3](ftp://ftp.musoftware.de/pub/uz/cc65/cc65-sources-2.13.3.tar.bz2).  The instructions assume that this file ended up in your Downloads folder in your home directory.
   3. In a terminal, run the following commands: <pre>
$ cd ~/Downloads
$ tar xvjf cc65-sources-2.13.3.tar.bz2
$ cd cc65-2.13.3
$ make -f make/gcc.mak
$ sudo make -f make/gcc.mak install
</pre>
   4. Install the [Apple // project template](https://github.com/jeremysrand/Apple2BuildPipeline/releases/download/1.0/Apple.XCode.Template.pkg).  The package is not signed so your Mac probably will not install it because it is untrusted.  To override this, hold the "Option" key down and right click on the package and select "Open" in the contextual menu.  You should now get an alert saying the package is unsigned but there is now an "Open" button.  Click "Open" to start the installer.

Everything you need is now installed.  To create a new Apple \]\[ project in Xcode:
   1. Start Xcode and create a new project by using File->New->Project...
   2. In the dialog, you will see an Apple \]\[ option below the OS X section.  Select that and select "Apple \]\[ Project".  Click "Next".
   3. A dialog box with a few text fields will appear.  In product name, put in the name of the Apple \]\[ executable you want to build.  Organization Name and Organization Identifier can be anything you want it to be.  Leave Build Tool set to "/usr/bin/make".  Click "Next".
   4. Xcode now prompts you where you want to save your project.  The name of the project will be the product name you already gave.  Pick a good directory for your project.  Your Documents foler is a reasonable option.  Click "Create".
   5. Your project is now ready for you.  If you select Product->Build, it will build and execute the template code in Virtual \]\[.  If everything works, you should see "HELLO, WORLD!" in the emulator.  Press any key in the emulator to quit the executable and go back to the BASIC prompt.
   6. Review the Makefile and set any options you want.  The file has lots of comments to help you understand the configuration options.
   7. Change main.c and write more code in new C or assembly files until you have the program you always wanted to build...

This build infrastructure can be used in a non-Mac environment.  You need cc65 and the instructions above for downloading and building it should be approximately correct for most UNIX-like environments.  From there, you can edit the Makefile and add new source files as described above.  Be sure to set PGM to the name of your executable in the Makefile.  When you build the project in a non-Mac environment, you should end up with a .dsk file but it will not try to execute that like it would on a Mac.  In theory, other emulators on the Mac or on other host systems could be added to the build infrastructure and feel free to add support for your favourite.

Acknowledgements:
=================

Thanks to Quinn Dunki and Carrington Vanston who were instrumental in getting this working.  [Carrington's presentation](http://monsterfeet.com/kfest/) at KansasFest 2014 is where the basic concepts of a better Apple \]\[ build environment were demonstrated.  [Quinn built on that](http://quinndunki.com/blondihacks/?p=1904) and included support for automatically starting the program in Virtual \]\[ using Applescript.  Without their work, I wouldn't have been able to create this.  Thanks!
