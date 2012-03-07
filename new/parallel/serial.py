import feedparser
import multiprocessing

LIST_OF_URLS = ['http://distrowatch.com/news/oggcast.xml', 'http://distrowatch.com/news/oggcast.xml', 'http://distrowatch.com/news/podcast.xml', 'http://distrowatch.com/news/podcast.xml', 'http://www.thesourceshow.org/xvid.xml', 'http://www.thesourceshow.org/xvid.xml', 'http://goinglinux.com/oggpodcast.xml', 'http://goinglinux.com/oggpodcast.xml', 'http://goinglinux.com/mp3podcast.xml', 'http://goinglinux.com/mp3podcast.xml', 'http://linuxcrazy.com/podcasts/ogg.xml', 'http://linuxcrazy.com/podcasts/ogg.xml', 'http://linuxcrazy.com/podcasts/Poderator.xml', 'http://linuxcrazy.com/podcasts/Poderator.xml', 'http://thebadapples.info/ogg.xml', 'http://thebadapples.info/ogg.xml', 'http://setbit.org/lt-ogg.xml', 'http://setbit.org/lt-ogg.xml', 'http://leoville.tv/podcasts/floss.xml', 'http://leoville.tv/podcasts/floss.xml', 'http://talkgeektome.us/ogg.xml', 'http://talkgeektome.us/ogg.xml', 'http://talkgeektome.us/mp3.xml', 'http://talkgeektome.us/mp3.xml', 'http://talkgeektome.us/flac.xml', 'http://talkgeektome.us/flac.xml', 'http://www2.madphilosopher.ca/bsdtalk_ogg.xml', 'http://www2.madphilosopher.ca/bsdtalk_ogg.xml', 'http://www.hwhq.com/rssOGG.xml', 'http://www.hwhq.com/rssOGG.xml', 'http://hwhq.com/rss.xml', 'http://hwhq.com/rss.xml', 'http://gopher.info-underground.net:70/iu/rss-iu.xml', 'http://gopher.info-underground.net:70/iu/rss-iu.xml', 'http://lottalinuxlinks.com/podcast/ogg.xml', 'http://lottalinuxlinks.com/podcast/ogg.xml', 'http://ubuntuos.com/podcast/ubuntuos-ogg.xml', 'http://ubuntuos.com/podcast/ubuntuos-ogg.xml', 'http://ubuntuos.com/podcast/ubuntuos-mp3.xml', 'http://ubuntuos.com/podcast/ubuntuos-mp3.xml', 'http://rss.ittoolbox.com/rss/security-investigator-podcast.xml', 'http://rss.ittoolbox.com/rss/security-investigator-podcast.xml', 'http://thelinuxbox.org/podcast.xml', 'http://thelinuxbox.org/podcast.xml', 'http://www.infonomicon.org/info.xml', 'http://www.infonomicon.org/info.xml', 'http://thelip.net/lipogg.xml', 'http://thelip.net/lipogg.xml', 'http://thelip.net/lipmp3.xml', 'http://thelip.net/lipmp3.xml', 'http://podcast.linuxgames.com/feeds.xml', 'http://podcast.linuxgames.com/feeds.xml', 'http://www.opennewsshow.org/ogg.xml', 'http://www.opennewsshow.org/ogg.xml', 'http://www.opennewsshow.org/mp3.xml', 'http://www.opennewsshow.org/mp3.xml', 'http://lottalinuxlinks.com/podcast/uclugogg.xml', 'http://lottalinuxlinks.com/podcast/uclugogg.xml', 'http://www.linuxworld.com/podcasts/linux/index.xml', 'http://www.linuxworld.com/podcasts/linux/index.xml', 'http://www.thebadapples.info/fedorareloaded/ogg.xml', 'http://www.thebadapples.info/fedorareloaded/ogg.xml', 'http://www.gutsygeeks.com/audio/podcast.xml.php', 'http://www.gutsygeeks.com/audio/podcast.xml.php', 'http://handheldheroes.net/rssOGG.xml', 'http://handheldheroes.net/rssOGG.xml', 'http://handheldheroes.net/rss.xml', 'http://handheldheroes.net/rss.xml', 'http://www.eff.org/rss/podcast/ogg.xml', 'http://www.eff.org/rss/podcast/ogg.xml', 'http://www.eff.org/rss/podcast/mp3.xml', 'http://www.eff.org/rss/podcast/mp3.xml', 'http://linuxcranks.info/ogg.xml', 'http://linuxcranks.info/ogg.xml', 'http://linuxvoid.technographer.net/soundfeed.xml', 'http://linuxvoid.technographer.net/soundfeed.xml', 'http://titradio.info/tit.xml', 'http://titradio.info/tit.xml', 'http://fossgeek.com/feeds/rss-ogg-full.xml', 'http://fossgeek.com/feeds/rss-ogg-full.xml', 'http://fossgeek.com/feeds/rss-mp3-full.xml', 'http://fossgeek.com/feeds/rss-mp3-full.xml', 'http://podcasts.jonmasters.org/kernel/kernel.xml', 'http://podcasts.jonmasters.org/kernel/kernel.xml', 'http://www.somethingkindatechy.org/pcg/feed.xml', 'http://www.somethingkindatechy.org/pcg/feed.xml', 'http://linuxgeekdom.com/rssogg.xml', 'http://linuxgeekdom.com/rssogg.xml', 'http://linuxgeekdom.com/rssmp3.xml', 'http://linuxgeekdom.com/rssmp3.xml', 'http://lottalinuxlinks.com/podcast/call-in.xml', 'http://lottalinuxlinks.com/podcast/call-in.xml', 'http://www.slugak.net/rss.xml', 'http://www.slugak.net/rss.xml', 'http://qskcast.info/netcasts/ogg/rss.xml', 'http://qskcast.info/netcasts/ogg/rss.xml', 'http://feeds.feedburner.com/HackRadioLive?format=xml', 'http://feeds.feedburner.com/HackRadioLive?format=xml', 'http://mikecosma.podomatic.com/rss2.xml', 'http://mikecosma.podomatic.com/rss2.xml', 'http://bsd.linuxbasix.com/feeds/regexorcist_ogg.xml', 'http://bsd.linuxbasix.com/feeds/regexorcist_ogg.xml']


def serial():
    for url in LIST_OF_URLS:
        parsed = feedparser.parse(url)
        if parsed.entries:
            print 'Found entry:', parsed.entries[0]

def parallel_with_twisted():
    from twisted.internet import reactor
    import twisted.internet.defer
    import twisted.web.client

    def handleResponse(parsed_feed):
        parsed = feedparser.parse(parsed_feed)
        if parsed.entries:
            print 'Found entry:', parsed.entries[0]

    semaphore = twisted.internet.defer.DeferredSemaphore(4)
    dl = twisted.internet.defer.DeferredList([
            semaphore.run(twisted.web.client.getPage, url).addBoth(handleResponse)
            for url in LIST_OF_URLS])
    dl.addBoth(lambda x: reactor.stop())
    reactor.run()

def parallel_with_gevent():
    import gevent.monkey
    gevent.monkey.patch_all()
    from gevent.pool import Pool

    # limit ourselves to max 10 simultaneous outstanding requests
    pool = Pool(10)

    def handle_one_url(url):
        parsed = feedparser.parse(url)
        if parsed.entries:
            print 'Found entry:', parsed.entries[0]

    for url in LIST_OF_URLS:
        pool.spawn(handle_one_url, url)
    pool.join()

def parallel_with_multiprocessing():
    def handle_one_url(url):
        parsed = feedparser.parse(url)
        if parsed.entries:
            print 'Found entry:', parsed.entries[0]

    pool = multiprocessing.Pool(processes=4)
    result = [pool.apply_async(handle_one_url(url,))
                              for url in LIST_OF_URLS]
    [i.get() for i in result]

if __name__ == '__main__':
    parallel_with_twisted()
