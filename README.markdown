JAPI
====

  https://github.com/ohlhaver/JAPI

DESCRIPTION:
============

  JAPI is ruby wrapper for Jurnalo RESTful API. Jurnalo.com is a web application which is built over top of Jurnalo RESTful API.
  It gives developer to create applications for their platform.

FEATURES/PROBLEMS:
==================

  JAPI converts the api response from Jurnalo RESTful API into business objects.

SYNOPSIS:
=========

  <pre><code>JAPI::Model::Base.client = JAPI::Client.new( :base_url => 'http://api.jurnalo.com', :access_key => 'YOUR_OWN_ACCESS_KEY' )</code></pre>
  
  To search for story
  
  <pre><code>stories = JAPI::Story.find( :all, :params => { :q => 'search terms' } )</code></pre>

REQUIREMENTS:
=============

- activesupport >= 2.3.4
- activeresource >= 2.3.4

INSTALL:
========

- sudo gem install JAPI

LICENSE:
========

(The MIT License)

Copyright (c) 2010 Jurnalo.com( Ram Singla )

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.