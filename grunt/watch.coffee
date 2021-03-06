module.exports =
    coffee:
        files: [
            'src/**/*.coffee',
            'example/**/*.coffee',
            'spec/**/*.coffee'
        ]
        tasks: [
            'coffee:compile',
            'browserify:dev',
            'browserify:karma',
            'coffeelint'
        ]
        options:
            livereload: true

    js:
        files: ['/']
        options:
            livereload: true

    compass:
        files: ['src/*.{scss,sass}']
        tasks: ['compass:server']

    css:
        files: ['<%= ng.buildFolder %>/style.css']
        options:
            livereload: true

    handlebars:
        files: 'src/**/*.handlebars'
        tasks: [
            'handlebars:compile'
        ]
        options:
            livereload: true

    karma:
        files: ['<%= ng.buildFolder %>/specs-bundle.js', 'karma.conf.js']
        tasks: ['karma:dev:run']