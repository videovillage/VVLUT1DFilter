# VVLUT1DFilter

[![CI Status](http://img.shields.io/travis/gregcotten/VVLUT1DFilter.svg?style=flat)](https://travis-ci.org/gregcotten/VVLUT1DFilter)
[![Version](https://img.shields.io/cocoapods/v/VVLUT1DFilter.svg?style=flat)](http://cocoadocs.org/docsets/VVLUT1DFilter)
[![License](https://img.shields.io/cocoapods/l/VVLUT1DFilter.svg?style=flat)](http://cocoadocs.org/docsets/VVLUT1DFilter)
[![Platform](https://img.shields.io/cocoapods/p/VVLUT1DFilter.svg?style=flat)](http://cocoadocs.org/docsets/VVLUT1DFilter)

VVLUT1DFilter is a custom Core Image Filter that applies a 1D look up tables (1D LUT) to an input image. LUTs are often used in film and video finishing, graphics, video games, and rendering.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

VVLUT1DFilter is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "VVLUT1DFilter"
    
## Requirements

At the moment this is Mac only - iOS does not support custom kernels. For the future, compiling this filter into an Image Unit may allow iOS support.

## Author

gregcotten, gregcotten@gmail.com

## License

VVLUT1DFilter is available under the MIT license.

