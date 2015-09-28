
# Mediathek Meta Data Maschine

Die Meta-Daten der Mediatheken der D-A-CH öffentlich-rechtlichen TV-Sender als Video-Podcasts in
maschinenlesbar.

## Anforderungen

### Leicht zu hosten

Webserver: Nur statische Dateien mit Metadaten (keine Videos).

Server: cron, dash-Skripte, debian sqeeze mit möglichst wenigen Abhängigkeiten.

    $ sudo apt-get install cron curl python libxml2-utils xsltproc raptor2-utils rsync lftp

### Neue Sendungen möglichst in Echtzeit

Veränderte Feedliste und Feeds benachrichtigen
[PubSubHubbub](https://de.wikipedia.org/wiki/PubSubHubbub)

Außerdem sind [`Last-Modified`](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.29) und
[`Expires`](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.21) richtig gesetzt.

### Sendungen als Video Podcast

[Atom](http://atomenabled.org/developers/syndication/) oder zur Not RSS mit mp4-enclosure, zum Abo
per

- http://itunes.com
- http://www.getmiro.com
- ?

### Handhabbare Datenmengen

Feed XMLs sollten unkomprimiert immer < 1MB sein, Webserver komprimiert.

### Standard Prozesse, Datenformate und Werkzeuge

- [HTTP/1.1](http://www.w3.org/Protocols/rfc2616/rfc2616.html)
- [RDF](https://www.w3.org/RDF/)
- [OPML](https://de.wikipedia.org/wiki/Outline_Processor_Markup_Language)
- [Atom](http://atomenabled.org/developers/syndication/), [RFC4287](https://tools.ietf.org/html/rfc4287)
- [PubSubHubbub](https://en.wikipedia.org/wiki/PubSubHubbub)
- [RelaxNG](http://blog.mro.name/2010/05/xml-toolbox-relax-ng-trang/)
- [`dash` oder `bash`](https://wiki.ubuntu.com/DashAsBinSh)
- [`xsltproc`](http://xmlsoft.org/XSLT/xsltproc.html)
- [`xmllint`](http://xmlsoft.org/xmllint.html)
- [`rapper`](http://librdf.org/raptor/rapper.html)
- [`curl`](http://curl.haxx.se/)
- [`json2xml.py`](https://github.com/axet/json2xml)
- [`rsync`](https://rsync.samba.org/)
- [`lftp`](http://lftp.yar.ru/lftp-man.html)

Evtl.

- [PHP: simple html dom](http://sourceforge.net/projects/simplehtmldom/)

### Datenbasis programm.ard.de und ardmediathek.de

- http://programm.ard.de/tv?datum=25.09.2015&hour=12

## Ablauf

1. frische Videos von http://programm.ard.de/tv?datum=23.09.2015&hour=20&sender=28725
2. pro Video zugehörigen RSS Feed finden (http://linkeddata.mro.name/open/tv/ardmediathek.de.opml)
   Film `bcastId` -> Feed `documentId`  
   Film Url: http://mediathek.daserste.de/FilmMittwoch-im-Ersten/Meister-des-Todes-Video-tgl-ab-20-Uhr/Das-Erste/Video?documentId=30734544&topRessort&bcastId=10318946  
   RSS Url: http://www.ardmediathek.de/tv/FilmMittwoch-im-Ersten/Sendung?documentId=10318946&rss=true
3. falls Video (Meta) unbekannt/veraltet:
  1. `documentId` -> mp4 via JSON http://www.ardmediathek.de/play/media/30734544
     `curl http://www.ardmediathek.de/play/media/30734544 | python bin/json2xml.py -r video | xmllint --format --encode utf8 -`
  2. sonstige ([dct](http://wiki.dublincore.org/index.php/User_Guide/Publishing_Metadata)) Meta aus Filmseite (HTML):
    - [`dct:valid`](http://wiki.dublincore.org/index.php/User_Guide/Publishing_Metadata#dcterms:valid)
    - [`dct:date`](http://wiki.dublincore.org/index.php/User_Guide/Publishing_Metadata#dcterms:date)
    - [`dct:title`](http://wiki.dublincore.org/index.php/User_Guide/Publishing_Metadata#dcterms:title)
    - [`dct:subject`](http://wiki.dublincore.org/index.php/User_Guide/Publishing_Metadata#dcterms:subject)
    - [`dct:abstract`](http://wiki.dublincore.org/index.php/User_Guide/Publishing_Metadata#dcterms:abstract)
    - [`dct:extent`](http://wiki.dublincore.org/index.php/User_Guide/Publishing_Metadata#dcterms:extent)
    - [`dct:format`](http://wiki.dublincore.org/index.php/User_Guide/Publishing_Metadata#dcterms:format)
    - [`dct:language`](http://wiki.dublincore.org/index.php/User_Guide/Publishing_Metadata#dcterms:language)
    - [`dct:publisher`](http://wiki.dublincore.org/index.php/User_Guide/Publishing_Metadata#dcterms:publisher)
4. Video markieren
5. Feed bereinigen (alte Meta-Daten entfernen), aktualisieren, pubsubhubbub

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