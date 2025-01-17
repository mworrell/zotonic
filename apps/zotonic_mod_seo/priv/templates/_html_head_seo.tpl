{% with m.rsc[id].id as id %}

{% block links %}
    {% if id and id.is_a.query and q.page %}
        <link rel="canonical" href="{% block canonical %}{{ id.page_url_abs }}{% endblock %}?page={{ q.page|escape }}" />
        <link rel="shortlink" href="{% block shortlink %}{% url id id=id absolute_url %}{% endblock %}" />
    {% elseif id %}
    	<link rel="canonical" href="{% block canonical %}{{ id.page_url_abs }}{% endblock %}" />
        <link rel="shortlink" href="{% block shortlink %}{% url id id=id absolute_url %}{% endblock %}" />
    {% endif %}
{% endblock %}

{% block metadata %}
    {% if m.seo.noindex or noindex %}
        <meta name="robots" content="noindex,nofollow">
    {% elseif zotonic_dispatch != `home`
            and id
            and id.page_path != '/'
            and id.language
            and not z_language|member:id.language
            and m.modules.active.mod_translation
    %}
        {# Take one of the alternative urls, provided by mod_translation #}
        <meta name="robots" content="noindex">
    {% elseif q.page and q.page > 1 %}
        {# Do not index beyond the first page of search results, but do follow links #}
        <meta name="robots" content="noindex">
    {% else %}
        {% with m.seo.keywords as keywords %}
        {% with m.seo.description as description %}
            {% if id %}
                {% if id.seo_noindex or id.category_id.is_seo_noindex_cat %}
                    <meta name="robots" content="noindex">
                {% else %}
                    {% with id.seo_keywords as seo_keywords %}
                        {% if seo_keywords %}
                            <meta name="keywords" content="{{ seo_keywords }}, {{ keywords|escape }}">
                        {% elseif id.o.subject as subjects %}
                            <meta name="keywords" content="{% for oid in subjects %}{{ oid.title }}, {% endfor %}{{ keywords|escape }}">
                        {% endif %}
                        <meta name="description" content="{{ id.seo_desc|default:(id|summary)|default:(description|escape)|truncate:400 }}">
                    {% endwith %}
                {% endif %}
            {% else %}
                {% if keywords %}
                    <meta name="keywords" content="{{ keywords|escape }}">
                {% endif %}
                {% if description %}
                    <meta name="description" content="{{ description|escape|truncate:400 }}">
                {% endif %}
            {% endif %}
        {% endwith %}
        {% endwith %}
    {% endif %}
{% endblock %}

{% block verification %}
    {% if m.seo.bing.webmaster_verify as wmv %}
        <meta name="msvalidate.01" content="{{ wmv }}">
    {% endif %}
    {% if m.seo.google.webmaster_verify as wmv %}
        <meta name="google-site-verification" content="{{ wmv }}">
    {% endif %}
    {% if m.seo.yandex.webmaster_verify as wmv %}
        <meta name="yandex-verification" content="{{ wmv }}">
    {% endif %}
{% endblock %}

{% block trackers %}
    {% with script_type|default:"text/javascript" as script_type %}
    {% if not m.acl.is_admin and not notrack %}
        {% if m.seo.google.analytics as ga %}
            {% if ga|match:"^G-" %}
                <script type="{{ script_type }}" async src="https://www.googletagmanager.com/gtag/js?id={{ ga|urlencode }}"></script>
                <script type="text/javascript" nonce="{{ m.req.csp_nonce }}">
                  window.dataLayer = window.dataLayer || [];
                  function gtag(){dataLayer.push(arguments);}
                  gtag('js', new Date());

                  gtag('config', '{{ ga|escapejs }}', { 'anonymize_ip': true });
                </script>
            {% else %}
                <script type="text/javascript" nonce="{{ m.req.csp_nonce }}">
                    var GA_LOCAL_STORAGE_KEY = 'ga:clientId';
                    var ga_options = {% include '_ga_params.tpl' %};
                    window.ga=window.ga||function(){(ga.q=ga.q||[]).push(arguments)};ga.l=+new Date;
                    if (window.localStorage) {
                      ga_options.storage = 'none';
                      ga_options.clientId = localStorage.getItem(GA_LOCAL_STORAGE_KEY);
                      ga('create', '{{ ga|escapejs }}', ga_options);
                      ga(function(tracker) {
                        localStorage.setItem(GA_LOCAL_STORAGE_KEY, tracker.get('clientId'));
                      });
                    }
                    else {
                      ga('create', '{{ ga|escapejs }}', 'auto', ga_options);
                    }
                    ga('set', 'anonymizeIp', true);
                    ga('send', 'pageview');
                </script>
                <script type="{{ script_type }}" async src='https://www.google-analytics.com/analytics.js'></script>
            {% endif %}
        {% endif %}
        {% if m.seo.google.gtm as gtm %}
            <script type="{{ script_type }}" nonce="{{ m.req.csp_nonce }}">
            (function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
            new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
            j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
            'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
            })(window,document,'script','dataLayer','{{ gtm|escapejs }}');
            </script>
        {% endif %}
    {% endif %}
    {% endwith %}
{% endblock %}

{% endwith %}
