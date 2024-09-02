/* extension.js
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import Gio from 'gi://Gio';
import GObject from 'gi://GObject';
import St from 'gi://St';
import GLib from 'gi://GLib';


import {Extension, gettext as _} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';
import * as PopupMenu from 'resource:///org/gnome/shell/ui/popupMenu.js';

import * as Main from 'resource:///org/gnome/shell/ui/main.js';

const filePathTLP = '/etc/tlp.conf';
const filePathPowerState = '/sys/class/power_supply/AC/online';

let powerState = 'Unknown'; // Create a variable to hold the power state 1 = AC, 0 = Battery

// TODO Make it so the timer triggers on a key press (Fn + B and F12)
// TODO make a hover or click tolip to show what each icon means in the bar
// smth to show what the icons are
// possible to have a enabled and disable button for each in the top bar?

// TODO add a prefs.js file to allow for changing the location in the panel

const Indicator = GObject.registerClass(
    class Indicator extends PanelMenu.Button { // Create the indicator which will go in the top panel
        _init() {
            super._init(0.0, _('Power Indicators'));



            let box = new St.BoxLayout({vertical: false}); // Create a box to hold the icons

            this.iconTHROTTLED = new St.Icon({
                icon_name: 'content-loading-symbolic',
                style_class: 'system-status-icon',
                visible: true,
            });

            this.iconLPM = new St.Icon({
                icon_name: 'battery-missing-symbolic',
                style_class: 'system-status-icon',
                visible: true,
            });

            this.iconPERFORMANCE = new St.Icon({
                icon_name: 'content-loading-symbolic',
                style_class: 'system-status-icon',
                visible: true,
            });

            box.add_child(this.iconTHROTTLED);
            box.add_child(this.iconLPM);
            box.add_child(this.iconPERFORMANCE);

            this.add_child(box);

        }

        updatePowerState() {
            let filePowerState = Gio.File.new_for_path(filePathPowerState); // Create a file object for the power state path

            filePowerState.load_contents_async(null, (file, res) => {
                try {
                    let [success, contents] = file.load_contents_finish(res);
                    if (success) {
                        let data = new TextDecoder('utf-8').decode(contents);
                        log('Power State contents: ' + data);

                        if (data.search('1') !== -1) { // If the returned index is not -1 then the power state is 1
                            log('Power State is AC');
                            powerState = 1;

                        } else if (data.search('0') !== -1) { // If the returned index is not -1 then the power state is 0
                            log('Power State is Battery');
                            powerState = 0;

                        } else {
                            log('WARNING: Power State not found. Something is VERY WRONG!.');
                        }

                    } else {
                        log('Failed to load contents of the file');
                    }
                } catch (e) {
                    log('Error loading power state file: ' + e.message);
                }

            });
        }

        updateIcons() {
            this.updatePowerState()

            let fileTLP = Gio.File.new_for_path(filePathTLP); // Create a file object for the tlp.conf path

            fileTLP.load_contents_async(null, (file, res) => {
                try {
                    let [success, contents] = file.load_contents_finish(res);
                    if (success) {
                        let data = new TextDecoder('utf-8').decode(contents);
                        // log('TLP contents: ' + data);

                        // TODO is there a way to decrease the verbosity of these three checks? can i pass in 3 strings to one function and will it work???? prolly not cause var names but maybe

                        // Update Throttled Icon
                        if (data.search('THROTTLED=1') !== -1) { // If the returned index is not -1 then LPM=1 is there
                            log('THROTTLED is enabled');
                            this.iconTHROTTLED.visible = true;
                            this.iconTHROTTLED.icon_name = 'power-profile-power-saver-symbolic';
                        } else if (data.search('THROTTLED=0') !== -1) { // Checking that it is disabled because a return of -1 could mean the entry has been deleted
                            log('THROTTLED is disabled');
                            this.iconTHROTTLED.visible = false;

                        } else {
                            log('WARNING: THROTTLED not found tlp.conf. Check file immediately.');
                        }

                        // Update LPM Icon
                        if (data.search('LPM=1') !== -1) { // If the returned index is not -1 then LPM=1 is there
                            log('LPM is enabled');
                            if (powerState === 0) {
                                this.iconLPM.visible = true;
                            } else if (powerState === 1) {
                                this.iconLPM.visible = false;
                            }
                            this.iconLPM.icon_name = 'battery-level-10-symbolic';
                        } else if (data.search('LPM=0') !== -1) { // Checking that it is disabled because a return of -1 could mean the entry has been deletded
                            log('LPM is disabled');
                            this.iconLPM.visible = false;

                        } else {
                            log('WARNING: LPM not found tlp.conf. Check file immediately.');
                        }

                        // Update Performance  Icon
                        if (data.search('PERF=1') !== -1) { // If the returned index is not -1 then LPM=1 is there
                            log('PERFORMANCE is enabled');
                            if (powerState === 1) {
                                this.iconPERFORMANCE.visible = true;

                            } else if (powerState === 0) {
                                this.iconPERFORMANCE.visible = false;
                            }

                            this.iconPERFORMANCE.icon_name = 'power-profile-performance-symbolic';
                        } else if (data.search('PERF=0') !== -1) { // Checking that it is disabled because a return of -1 could mean the entry has been deleted
                            log('PERFORMANCE is disabled');
                            this.iconPERFORMANCE.visible = false;

                        } else {
                            log('WARNING: PERFORMANCE not found tlp.conf. Check file immediately.');
                        }

                    } else {
                        log('Failed to load contents of the file');
                    }
                } catch (e) {
                    log('Error loading TLP.conf: ' + e.message);
                }

            });
        }
    });

export default class PowerIndicator extends Extension {
    enable() {
        log('PowerIndicator enabled');
        this._indicator = new Indicator();

        // Add keybinding
        global.display.add_keybinding(
            'throttled',
            new Gio.Settings({ schema_id: 'org.gnome.shell.extensions.my-extension' }),
            Meta.KeyBindingFlags.NONE,
            Shell.ActionMode.NORMAL,
            updateIcons
        );
        global.display.add_keybinding(
            'toggler',
            new Gio.Settings({ schema_id: 'org.gnome.shell.extensions.my-extension' }),
            Meta.KeyBindingFlags.NONE,
            Shell.ActionMode.NORMAL,
            updateIcons
        );

        // Add the indicator to the status area
        Main.panel.addToStatusArea(this.uuid, this._indicator);

        // Create a timer to update the panel icon
        this._timer = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 8, () => { // TODO how fast can this refresh.....
            this._indicator.updateIcons();
            return GLib.SOURCE_CONTINUE;
        });
    }

    disable() {
        log('PowerIndicator disabled');
        if (this._timer) {
            GLib.source_remove(this._timer);
            this._timer = null;
        }

        // Remove keybinding
        global.display.remove_keybinding('throttled');
        global.display.remove_keybinding('toggler');

        this._indicator.destroy();
        this._indicator = null;
    }
}
