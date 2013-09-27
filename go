#!/bin/bash  
ruby align.rb eng_conf_short.txt fr_conf_short.txt $1
ruby align.rb eng_conf.txt fr_conf.txt $1
ruby align.rb eng_conf.txt de_conf.txt $1
ruby align.rb gutenberg_intro_en.txt gutenberg_intro_fr.txt $1