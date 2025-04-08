#!/usr/bin/env bash

cp -R ../_themes/DevBlog-Theme/assets/fontawesome/js ../app/javascript/src/fontawesome
cp -R ../_themes/DevBlog-Theme/assets/css/. ../app/assets/stylesheets
cp ../_themes/DevBlog-Theme/assets/plugins/popper.min.js ../app/javascript/src
cp ../_themes/DevBlog-Theme/assets/plugins/bootstrap/js/bootstrap.min.js ../app/javascript/src

echo "The DevBlog-Theme was installed successfully!"
