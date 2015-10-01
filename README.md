
# Mediathek Meta Maschine

Die Mediatheken der D-A-CH öffentlich-rechtlichen TV-Sender als Video-Podcasts.

Zunächst ARD, schrittweise (aber evtl. langsam) mehr.

## Beispiel

http://linkeddata.mro.name/open/tv/mediathek/ardmediathek.de/feeds/index.opml

## Installation

    $ sudo apt-get install git cron curl libxml2-utils xsltproc
    $ mkdir $HOME/Documents && cd $HOME/Documents
    $ git clone https://github.com/mro/tv-mediathek.git && cd tv-mediathek/ardmediathek.de/bin
    $ vim create-feeds-opml.settings
    $ vim cron.sh
    $ crontab -e
    15,45 * * * * cd $HOME/Documents/tv-mediathek/ardmediathek.de && nice sh bin/cron.sh 1> tmp/stdout.log 2> tmp/stderr.log

## Anforderungen

### Leicht zu installieren und zu hosten

Webserver: Nur statische Dateien mit Metadaten (keine Videos).

Server: cron, dash-Skripte, debian wheezy mit möglichst wenigen Abhängigkeiten.

Siehe [Installation](#installation) unten.

### Neue Sendungen möglichst in Echtzeit

Veränderte Feedliste und Feeds benachrichtigen
[PubSubHubbub](https://de.wikipedia.org/wiki/PubSubHubbub)

Außerdem ist [`Last-Modified`](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.29) evtl.
[`Expires`](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.21) richtig gesetzt.

### Sendungen als Video Podcast

[![Atom Feed Logo](https://rawgithub.com/mro/tv-mediathek/master/ardmediathek.de/pub/assets/atomenabled.svg)](http://atomenabled.org)
zum Abo per

- http://itunes.com
- http://www.getmiro.com
- all [Atom-enabled Podcatchers - see column `BH`](https://docs.google.com/spreadsheets/d/1c2L14UVH1xtN4iDG4awheLbMgPCQgaKEamUauWs1gps/edit?pli=1#gid=0)

### Handhabbare Datenmengen

Feed XMLs sollten unkomprimiert immer < 1MB sein, Webserver komprimiert.

Ggf. '[Paged Feeds](http://tools.ietf.org/html/rfc5005)'.

### Standard Prozesse, Datenformate und Werkzeuge

Standards

- [Atom](http://atomenabled.org/developers/syndication/), [RFC4287](https://tools.ietf.org/html/rfc4287)
- [OPML](https://de.wikipedia.org/wiki/Outline_Processor_Markup_Language)
- [PubSubHubbub](https://en.wikipedia.org/wiki/PubSubHubbub)
- [XSLT 1.0](http://www.w3.org/TR/xslt/)
- [HTTP/1.1](http://www.w3.org/Protocols/rfc2616/rfc2616.html)

Werkzeuge

- [`dash` oder `bash`](https://wiki.ubuntu.com/DashAsBinSh)
- [`curl`](http://curl.haxx.se/)
- [`cron`](https://packages.debian.org/de/wheezy/cron)
- [`xsltproc`](http://xmlsoft.org/XSLT/xsltproc.html)
- [`xmllint`](http://xmlsoft.org/xmllint.html)

Später evtl.

- [RDF](https://www.w3.org/RDF/)
- [RelaxNG](http://blog.mro.name/2010/05/xml-toolbox-relax-ng-trang/)
- [`rapper`](http://librdf.org/raptor/rapper.html)
- [`rsync`](https://rsync.samba.org/)
- [`lftp`](http://lftp.yar.ru/lftp-man.html)

### Datenquelle ardmediathek.de

- http://www.ardmediathek.de/tv/sendungVerpasst?tag=0
- http://www.ardmediathek.de/export/rss/id=1458
- http://www.ardmediathek.de/play/media/30786788

Später evtl.

- http://www.ardmediathek.de/tv/Die-Sendung-mit-der-Maus/Die-Sendung-mit-der-Maus-vom-27-09-2015-/Das-Erste/Video?documentId=30786788&bcastId=1458
- http://programm.ard.de/tv?datum=25.09.2015&hour=12

## Ablauf

### Minimalvariante

- alle Sendungen (des Tages? Der letzten Stunde?) abklappern (http://www.ardmediathek.de/tv/sendungVerpasst?tag=0) und deren Feeds auflisten,
- die RSS Feed URL Form http://www.ardmediathek.de/export/rss/id=1458 benutzen, laden und cachen,
- gucken ob der SHA sich geändert hat,
- einen Atom Feed bauen,
- mit `enclosure`s etc. aus der vorherigen Version anreichern,
- unbekannte enclosures per `documentId` und http://www.ardmediathek.de/play/media/30757328 ergänzen,
- dasselbe evtl. für `content` etc.,
- speichern, SHA, deploy, ggf, pubsubhubbub.
- Liste aller Feeds erstellen aus http://www.ardmediathek.de/tv/sendungen-a-z

    index.opml
    1458/feed.atom

### Ausbaustufen

- sonstige ([dct](http://wiki.dublincore.org/index.php/User_Guide/Publishing_Metadata)) Meta aus [Filmseite (HTML)](http://www.ardmediathek.de/tv/Die-Sendung-mit-der-Maus/Die-Sendung-mit-der-Maus-vom-27-09-2015-/Das-Erste/Video?documentId=30786788&bcastId=1458):
	- [`dct:valid`](http://wiki.dublincore.org/index.php/User_Guide/Publishing_Metadata#dcterms:valid)
	- [`dct:date`](http://wiki.dublincore.org/index.php/User_Guide/Publishing_Metadata#dcterms:date)
	- [`dct:title`](http://wiki.dublincore.org/index.php/User_Guide/Publishing_Metadata#dcterms:title)
	- [`dct:subject`](http://wiki.dublincore.org/index.php/User_Guide/Publishing_Metadata#dcterms:subject)
	- [`dct:abstract`](http://wiki.dublincore.org/index.php/User_Guide/Publishing_Metadata#dcterms:abstract)
	- [`dct:extent`](http://wiki.dublincore.org/index.php/User_Guide/Publishing_Metadata#dcterms:extent)
	- [`dct:format`](http://wiki.dublincore.org/index.php/User_Guide/Publishing_Metadata#dcterms:format)
	- [`dct:language`](http://wiki.dublincore.org/index.php/User_Guide/Publishing_Metadata#dcterms:language)
	- [`dct:publisher`](http://wiki.dublincore.org/index.php/User_Guide/Publishing_Metadata#dcterms:publisher)

## Qualität

| Quality         | very good | good | normal | irrelevant |
|-----------------|:---------:|:----:|:------:|:----------:|
| Functionality   |           |      |    ×   |            |
| Reliability     |           |  ×   |        |            |
| Usability       |           |  ×   |        |            |
| Efficiency      |     ×     |      |        |            |
| Changeability   |           |  ×   |        |            |
| Portability     |           |      |    ×   |            |

## Mengengerüst

- 1000 RSS Feeds auf 24 Gruppen verteilt,
- 1000 Videos pro Feed,
- 20000 Videos insgesamt,
- Update alle 30 Min.

## Lizenz

- Software: [The Human Rights License](LICENSE.txt)
- Daten, Vorschlag: [Namensnennung - Weitergabe unter gleichen Bedingungen 3.0 Deutschland (CC BY-SA 3.0 DE)](http://creativecommons.org/licenses/by-sa/3.0/de/)

## Inspiriert von

- https://github.com/xaverW/MediathekView
- https://web.archive.org/web/20121210030455/http://appdrive.net/mediathek/
- http://purl.mro.name/radio-pi/
- https://github.com/raptor2101/Mediathek
- https://github.com/michaelw/mediathek-dl
- http://podlove.org/
