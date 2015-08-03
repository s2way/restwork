module.exports = (grunt) ->

    config =
        pkg: grunt.file.readJSON 'package.json'
        coffee:
            compile:
                expand: true
                flatten: false
                cwd: 'app'
                src: ['**/*.coffee']
                dest: 'cov'
                ext: '.js'
        coffeelint:
            app: ['app/**/*.coffee']
            options:
                configFile: 'coffeelint.json'
        mochaTest:
            progress:
                options:
                    reporter: 'progress'
                    require: ['coffee-script/register', 'blanket']
                    captureFile: 'mochaTest.log'
                    quiet: false,
                    clearRequireCache: false
                src: ['app/test/**/*.coffee']
            spec:
                options:
                    reporter: 'spec'
                    require: ['coffee-script/register', 'blanket']
                    captureFile: 'mochaTest.log'
                    quiet: false,
                    clearRequireCache: false
                src: ['app/test/**/*.coffee']
        exec:
            cov: "rm -rf cov; mkdir -p cov; coffee --compile --output cov app; multi='mocha-cov-reporter=- html-cov=coverage.html' ./node_modules/mocha/bin/mocha cov/test -r blanket --reporter mocha-multi --compilers coffee:coffee-script/register --recursive"
        watch:
            src:
                files: ['app/**/**/*.coffee']
                tasks: ['lint', 'test', 'compile', 'coverage']
            gruntfile:
                files: ['Gruntfile.coffee']

    grunt.initConfig config

    require('load-grunt-tasks')(grunt)

    grunt.registerTask 'default', 'Watch', ->
        grunt.task.run 'watch'
    grunt.registerTask 'lint', ['coffeelint']
    grunt.registerTask 'compile', ['coffee:compile']
    grunt.registerTask 'test', ['mochaTest:progress']
    grunt.registerTask 'coverage', ['exec:cov']
