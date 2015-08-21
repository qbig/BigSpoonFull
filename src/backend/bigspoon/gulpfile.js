var gulp = require('gulp'),
    path = require('path'),
    livereload = require('gulp-livereload');

gulp.task('watch', function() {
  livereload.listen(35729);
  gulp.watch([
            path.resolve(__dirname, 'bigspoon/templates/*.html'),
            path.resolve(__dirname, 'bigspoon/assets/css/*.css'),
            path.resolve(__dirname, 'bigspoon/assets/js/*.js')
        ]).on('change', function(event) {
            livereload.reload();
            console.log('File', event.path, 'was', event.type);
            console.log('LiveReload is triggered!');
        });
});