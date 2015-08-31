**ATSCgh**—*Classes for Extracting Schedule Data From Digital TV Streams*
-
Author [Glenn R. Howes](mailto:glenn@genhelp.com), *owner [Generally Helpful Software](http://genhelp.com)*

### Introduction
I wrote an iOS app [Schedules GH] (http://AppStore.com/SchedulesGH), which hasn't sold well, but took a large amount of time to write. Mainly because it involved writing code to support digital TV's [ATSC specification](http://atsc.org/standard/a53-atsc-digital-television-standard/). This library does not include any way of retrieving the actual data. libHDHomerun for extracting data from an HDHomerun is released under LGPL, so it might be possible to use a loadable library which calls it. (Or you could contact Silicon Dust for a side license.)

Given that this was all code written for iOS in 2013, it is written in Objective-C.


### Features
Given a series of data blocks from an over the air data stream, the idea is to stitch together a series of tables. This can do so.


### Limitations
There is one rare form of compressed unicode, Standard Compression Scheme for Unicode (SCSU) which I'm not yet supporting. If anyone knows how to do so without including a large 3rd party library, let me know.

This has been tested only on broadcast ATSC in the United States, actually only in the Boston area, so code paths that require other language settings have not been run through. 

This is not a completed solution. There is no demo app, it's just a set of classes that could be used to extract data if given the chance. If you want to use this in an app, I suggest creating an object which implements the **TVTuner** protocol and then try to call the ScheduleExtractor's **startWholeScanWithCallback:** class method.