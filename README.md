# Boxer Sunrise

This is the current interation of the historic Boxer project.

## Supported Platforms

Currently Boxer is tested on Intel versions of MacOS 10.13 High Sierra, 10.14 Mojave, 10.15 Catalina, and
11 Big Sur. These all use Lispworks 7.1.2. The Windows version on Lispworks is not far behind, and is expected
to be added the tested platforms in March 2021. Some work remains for Linux on Lispworks.

Boxer can be run and developed against using the freely available version of Lispworks. However, in order to
build deliverable binaries a professional license is required.

Work is in progress to run Boxer against fully open source versions of common lisp, focused primarily on SBCL.
Additionally the ability to run the core boxer evaluator separately to integrate with new web ecosystems (such
as node and a possible server side Boxer).

### Running the unit tests and UI in development

#### Dependencies

- Lispworks 7.1.2
  Lispworks should be fully patches, and for Big Sur, require the extra private-patches addition from lispworks.
  (as of 2021-01-27)
- Quicklisp loaded
  Quicklisp should be installed and available. The personal version of lispworks may require you to load it
  manually on each startup.
- Freetype2 Dev libraries
  The freetype2 development headers and libraries need to be installed. On MacOS this can be installed with
  homebrew as `brew install freetype2`

With the above installed and a lispworks Listener open, the following will compile and startup Boxer (adjusting the
path accordingly to your system.)

```lisp
;; This needs to be a full path to the bootstrap file
(load #P"~/code/boxer-sunrise/src/bootstrap.lisp")
```

### Building the Boxer executable on MacOS

*in-progress These instructions are being updated still for several binary libraries that need to be included
in the build*

MacOS application bundles can be created with the following delivery script. This will assume you have lispworks
installed and have the executable in the path. This has been tested with Lispworks 7.1. While you can run Boxer
from the personal edition of Lispworks, you will need on of the paid Profession versions that include the framework
for creating application binaries. (In Lispworks this is called the `delivery` framework).

```bash
git clone git@github.com:sgithens/boxer-sunrise.git
cd boxer-sunrise
lispworks -build src/delivery-script.lisp
```

You will now find a double-clickable MacOS application in `boxer-sunrise/data/boxersunrise.app`.


## Authors through the years

* Andrea A. diSessa
* Hal Abelson
* David Neves
* Eric Tenenbaum
* Gregor Kiczales
* Edward H. Lay
* Leigh Klotz
* Steven W. Githens
