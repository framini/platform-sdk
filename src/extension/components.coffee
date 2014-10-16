((root, factory) ->

    module.exports = factory(root, {})

)(window, (root, Ext) ->

    Base = require('./../base.coffee')

    class Component

        # object to store initialized components
        @initializedComponents : {}

        ###*
         * [startAll description]
         * @author Francisco Ramini <francisco.ramini at globant.com>
         * @param  {[type]} selector = 'body'. CSS selector to tell the app where to look for components
         * @return {[type]}
        ###
        @startAll: (selector = 'body', app) ->

            components = Component.parseList(selector, app.config.namespace)

            Base.log.info "Parsed components"
            Base.log.debug components

            # TODO: Proximo paso inicializar las componentes
            Component.instantiate(components, app)

            return Component.initializedComponents

        @parseList: (selector, namespace) ->
            # array to hold parsed components
            list = []

            namespaces = ['platform']

            # TODO: Add the ability to pass an array/object of namespaces instead of just one
            namespaces.push namespace if namespace isnt 'platform'

            cssSelectors = []

            # TODO: access this utils function through Base
            _.each namespaces, (ns, i) ->
                # if a new namespace has been provided lets add it to the list
                cssSelectors.push "[data-" + ns + "-component]"

            # TODO: Access these DOM functionality through Base
            $(selector).find(cssSelectors.join(',')).each (i, comp) ->

                ns = do () ->
                    namespace = ""
                    _.each namespaces, (ns, i) ->
                        # This way we obtain the namespace of the current component
                        if $(comp).data(ns + "-component")
                            namespace = ns

                    return namespace

                # options will hold all the data-* related to the component
                options = Component.parseComponentOptions(@, ns)

                list.push({ name: options.name, options: options })

            return list

        @parseComponentOptions: (el, namespace, opts) ->
            # TODO: access this utils function through Base
            options = _.clone(opts || {})
            options.el = el

            # TODO: access this DOM function through Base
            data = $(el).data()
            name = ''
            length = 0

            # TODO: access this utils function through Base
            $.each data, (k, v) ->

                # removes the namespace
                k = k.replace(new RegExp("^" + namespace), "")

                # decamelize the option name
                k = k.charAt(0).toLowerCase() + k.slice(1)

                # if the key is different from "component" it means it is
                # an option value
                if k != "component"
                    options[k] = v
                    length++
                else
                    name = v

            # add one because we've added 'el' automatically as an extra option
            options.length = length + 1

            # build ad return the option object
            Component.buildOptionsObject(name, options)

        
        @buildOptionsObject: (name, options) ->

            options.name = name

            return options

        @instantiate: (components, app) ->
             
            if components.length > 0

                m = components.shift()

                # Check if the modules are defined using the modules namespace
                # TODO: Provide an alternate way to define which is gonna be
                # this global object that is gonna hold the module definition
                if not _.isEmpty(NGL.modules) and NGL.modules[m.name] and m.options
                    mod = _.clone NGL.modules[m.name]

                    # create a new sandbox for this module
                    sb = app.createSandbox(m.name)

                    # generates an unique guid for the module
                    m.options.guid = _.uniqueId(m.name + "_")

                    # inject the sandbox and the options in the module proto
                    _.extend mod, sandbox : sb, options: m.options

                    # init the module
                    mod.initialize()

                    # store a reference of the generated guid on the el
                    $(mod.options.el).data '__guid__', m.options.guid

                    # saves a reference of the initialized module
                    Component.initializedComponents[ m.options.guid ] = mod

                Component.instantiate(components, app)


    ##
    # returns an object with the initialize method that will init the extension
    ##

    # constructor
    initialize : (app) ->

        Base.log.info "[ext] Component extension initialized"

        initializedComponents = {}

        app.sandbox.startComponents = (list, app) ->

            initializedComponents = Component.startAll(list, app)

        app.sandbox.getInitializedComponents = () ->

            return initializedComponents


    # this method will be called once all the extensions have been loaded
    afterAppStarted: (app) ->

        Base.log.info "Llamando al afterAppStarted"

        app.sandbox.startComponents(null, app)

    name: 'Component Extension'

    # this property will be used for testing purposes
    # to validate the Component class in isolation
    classes : Component

    # The exposed key name that could be used to pass options
    # to the extension.
    # This is gonna be used when instantiating the Core object.
    # Note: By convention we'll use the filename
    optionKey: 'components'
)