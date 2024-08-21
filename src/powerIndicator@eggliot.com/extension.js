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

const filePath = '/etc/tlp.conf';

// TODO Could make it display Performance mode if on AC and display LPM if on bat? Use an UP arrow or smth
// TODO Make it so the timer triggers on a key press (Fn + B and F12)

const Indicator = GObject.registerClass(
    class Indicator extends PanelMenu.Button { // Create the indicator which will go in the top panel
        _init() {
            super._init(0.0, _('LPM and THROTTLED Indicators'));

            let box = new St.BoxLayout({vertical: false}); // Create a box to hold the icons

            this.iconLPM = new St.Icon({
                icon_name: 'battery-missing-symbolic',
                style_class: 'system-status-icon',
                visible: true,
            });

            this.iconTHROTTLED = new St.Icon({
                icon_name: 'reaction-add-symbolic',
                style_class: 'system-status-icon',
                visible: true,
            });


            box.add_child(this.iconLPM);
            box.add_child(this.iconTHROTTLED);

            this.add_child(box);

        }

        updateIcons() {
            let file = Gio.File.new_for_path(filePath); // Create a file object for the tlp.conf path

            file.load_contents_async(null, (file, res) => {
                try {
                    let [success, contents] = file.load_contents_finish(res);
                    if (success) {
                        let data = new TextDecoder('utf-8').decode(contents);
                        // log('TLP contents: ' + data);

                        // Update LPM Icon
                        if (data.search('LPM=1') !== -1) { // If the returned index is not -1 then LPM=1 is there
                            log('LPM is enabled');
                            this.iconLPM.visible = true;
                            this.iconLPM.icon_name = 'battery-level-10-symbolic';
                        } else if (data.search('LPM=0') !== -1) { // Checking that it is disabled because a return of -1 could mean the entry has been deletded
                            log('LPM is disabled');
                            this.iconLPM.visible = false;

                        } else {
                            log('WARNING: LPM not found tlp.conf. Check file immediately.');
                        }

                        // Update Throttled Icon
                        if (data.search('THROTTLED=1') !== -1) { // If the returned index is not -1 then LPM=1 is there
                            log('THROTTLED is enabled');
                            this.iconTHROTTLED.visible = true;
                            this.iconTHROTTLED.icon_name = 'branch-compare-arrows-symbolic';
                        } else if (data.search('THROTTLED=0') !== -1) { // Checking that it is disabled because a return of -1 could mean the entry has been deleted
                            log('THROTTLED is disabled');
                            this.iconTHROTTLED.visible = false;

                        } else {
                            log('WARNING: THROTTLED not found tlp.conf. Check file immediately.');
                        }

                    } else {
                        log('Failed to load contents of the file');
                    }
                } catch (e) {
                    log('Error loading file: ' + e.message);
                }

            });
        }
    });

export default class PowerIndicator extends Extension {
    enable() {
        log('PowerIndicator enabled');
        this._indicator = new Indicator();

        // Add the indicator to the status area
        Main.panel.addToStatusArea(this.uuid, this._indicator);

        // Create a timer to update the panel icon
        this._timer = GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 8, () => {
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
        this._indicator.destroy();
        this._indicator = null;
    }
}