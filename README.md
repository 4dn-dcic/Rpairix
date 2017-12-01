## Rstarter [![Build Status](https://travis-ci.org/hms-dbmi/Rstarter.svg?branch=master)](https://travis-ci.org/hms-dbmi/Rstarter) <a href="https://codecov.io/gh/hms-dbmi/Rstarter"><img src="https://codecov.io/gh/hms-dbmi/Rstarter/branch/master/graph/badge.svg" /></a>

* You can use this repo as a template to create an R package. Make changes as you wish and run `git commit` and `git push`.
* The R package is auto-tested on Travis.

### Requirements
* R>=3.1
* You need `devtools` installed on your R
```r
install.packages("devtools")
```

### How to start
* First, clone this repo to your github account and change name.
```
$ git clone https://hms-dbmi/Rstarter
$ cd Rstarter
$ rm -rf .git
$ git remote add origin https://github.com/hms-dbmi/<MyPackageName>.git
$ git push -u origin master
```

* Modify the content as below.
* Get a Travis account and turn on Travis testing on this repo.

### How to change package name
* change file name `Rstarter.Rproj` to `<MyPackageName>.Rproj`
* edit the file `DESCRIPTION` and replace `Rstarter` with `<MyPackageName>`
* (optionally) edit this `README.md` file (replace `Rstarter` with `<MyPackageName>`, `hms-dbmi` with your github account, below line 50) 

### How to add a function to the package
* Create a function file inside the `R/` directory and run `library(devtools); document()` in R.
  * The R commands will create an Rd file and add the function to NAMESPACE. This needs to be done before `git commit` and `git push`
  * For the format of a function file, see example `R/hello.R`.
  * Use one file per function.
  * The examples in the function file are actually run during a Travis test.

### How to change version
* edit the version number in files `DESCRIPTION` and `<MyPackageName>.Rproj`
* edit the version number in this `README.md` as well, if applicable (if you want to keep version number in `README.md`).
* (optionally, to allow installation of specific release) Create a release on Github that matches the new version number (e.g. `0.0.1`)

### How to add data
* data files can be added to the package under the `inst` directory.

### More complex scenarios
* Some more complex examples may be found in https://github.com/4dn-dcic/Rpairix


***
***


## Table of contents
* [Installation](#installation)
* [Available R functions](#available-r-functions)
* [Example run](#example-run)
* [For developers](#for-developers)
* [Version history](#version-history)

## Installation
```r
library(devtools)
install_github("hms-dbmi/Rstarter")
```
Alternatively,
```bash
git clone https://github.com/hms-dbmi/Rstarter/
cd Rstarter
R --no-site-file --no-environ --no-save --no-restore CMD INSTALL --install-tests .
```
To install a specific version,
```r
library(devtools)
install_url("https://github.com/hms-dbmi/Rstarter/archive/0.0.1.zip")
```


## Available R functions
`hello`

## Example run
```r
> library(Rstarter)
>
> hello()
[1] "Hello World!"
[1] 12
>
> hello('hahaha')
[1] "hahaha"
[1] 6
>
> hello('hahaha',FALSE)  # different message, character count only
[1] 6
```

***

## For developers
When you modify the repo, rebuild the R package before your commit/push:
```
library(devtools)
document()
```

***

## Version history
### 0.0.1
* initial release



