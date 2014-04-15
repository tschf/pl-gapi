pl-gapi
=======

A PL/SQL Google API written primarily for Oracle Application Express (ApEx).

###Motivation

This started with wanting to figure out how to interface with Google data from ApEx, and began with inserting and fetching data from Calendar (which is not yet included in this libary). It then tranformed to interfacing with Drive - that is, being able to upload files into google drive, and storing the reference in a table. That inspired me to begin a project that is more easily integrated, with a set of packages for each Google service independent of one another.

###Authorization

The design of Authorization is to return the refresh token in the URL. ApEx escapes some special characters, so when storing them, it is necessary to un-escape the token to make them usable. I have been using utl\_i18n.unescape\_reference with success for this. For more information on authorization, please refer to the [wiki](wiki/Authorization).

###Contributing

Please, if you have a need for any particular Google API - do extend this library and create a pull request so that this can eventually be *the* best library for integrating with ApEx. Each service tends to have a set of functions for each resource. So as far as package naming goes, please follow the convention: GAPI\_*SERVICE*\_*RESOURCE* - where *SERVICE* is the Google service such as Calendar, Drive, etc and *RESOURCE* is the component of the API.

Please also extend the sample application with a new tab for the *SERVICE* - with a region at the top for the authorization, and then a region below for each action, wherever possible.

###Demo

Due to the process required to set this up, it is not possible to host a public demo on http://apex.oracle.com. However, I have a sample application which I use to test each service and to fetch a token. I encourage you to follow the installation steps in the wiki, and installing the application in your local environment.

###Usage

This API is still in early stages of development, so usage of this API in production systems should be done so with caution.

###Documentation

Please refer to the (wiki)[wiki) for full documentation.
