# Wallpaper changer - Bing

- **Operating system:** Linux (Ubuntu or other with GNOME desktop)

Download a new Bing wallpaper for the day and set it as your desktop background.


### Usage

1. Download or clone this repository
2. Open the program directory in terminal and run `bundle install` to get all the dependencies.
3. Run `ruby wallpaper_changer_bing.rb` to update your wallpaper. You can run it manually, or use GNOME's Startup Applications to make it run every time you turn on your computer.

**Note:** You should have Ruby installed on your system. If it's not already, follow the instructions given [here](https://www.ruby-lang.org/en/documentation/installation/) to install it.


### Settings

Write a YAML config file (`config/custom.yml`) to set:
- your wallpaper directory (`:wallpaper_dir`) - where downloaded images shall be kept
- how often to update the wallpaper (`:delay_in_days`)
- whether to log program actions and in which file (`:log`)

As a reference, use `config/default.yml`, where all the possible settings are shown.
