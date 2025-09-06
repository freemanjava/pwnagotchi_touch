import logging
from PIL import Image, ImageDraw, ImageFont
import pwnagotchi.ui.fonts as fonts
from pwnagotchi.ui.components import *
from pwnagotchi.ui.view import View


class InteractiveView(View):
    def __init__(self, config, impl, state=None):
        super().__init__(config, impl, state)
        self._ui_controller = None
        self._touch_zones_visible = True

        # Define touch zone layout for 250x122 display
        self._zones = {
            'menu': {'pos': (5, 5), 'size': (75, 30), 'label': 'MENU'},
            'action': {'pos': (85, 5), 'size': (75, 30), 'label': 'ACTION'},
            'stop': {'pos': (170, 5), 'size': (75, 30), 'label': 'STOP'},
            'bt_scan': {'pos': (5, 45), 'size': (115, 30), 'label': 'BT SCAN'},
            'bt_util': {'pos': (130, 45), 'size': (115, 30), 'label': 'BT UTILS'},
            'status': {'pos': (5, 85), 'size': (240, 32), 'label': 'Status'}
        }

    def set_ui_controller(self, controller):
        """Set the UI controller reference"""
        self._ui_controller = controller

    def on_render(self, canvas, force=False):
        """Custom render method for interactive UI"""
        if self._frozen and not force:
            return

        if canvas is None:
            return

        try:
            # Clear canvas
            draw = ImageDraw.Draw(canvas)
            draw.rectangle([0, 0, 250, 122], fill=self._white)

            # Draw touch zones if enabled
            if self._touch_zones_visible:
                self._draw_touch_zones(draw)

            # Draw status information
            self._draw_status_info(draw)

            # Draw activity indicators
            self._draw_activity_indicators(draw)

        except Exception as e:
            logging.error(f"Error in interactive view render: {e}")

    def _draw_touch_zones(self, draw):
        """Draw touch zone boundaries and labels"""
        try:
            for zone_name, zone_info in self._zones.items():
                x, y = zone_info['pos']
                w, h = zone_info['size']
                label = zone_info['label']

                # Draw zone border
                if zone_name == 'status':
                    # Status area - different style
                    draw.rectangle([x, y, x + w, y + h], outline=self._black, width=1)
                else:
                    # Button areas
                    draw.rectangle([x, y, x + w, y + h], outline=self._black, width=2)

                # Draw zone label
                try:
                    font = fonts.Small
                    text_w, text_h = draw.textsize(label, font=font)
                    text_x = x + (w - text_w) // 2
                    text_y = y + (h - text_h) // 2
                    draw.text((text_x, text_y), label, font=font, fill=self._black)
                except:
                    # Fallback if textsize not available
                    draw.text((x + 5, y + 5), label, fill=self._black)

        except Exception as e:
            logging.error(f"Error drawing touch zones: {e}")

    def _draw_status_info(self, draw):
        """Draw current status information"""
        try:
            if self._ui_controller:
                status = self._ui_controller.get_status()

                # Main status text in status area
                status_text = status.get('status_message', 'Ready')
                font = fonts.Small

                # Truncate if too long
                if len(status_text) > 35:
                    status_text = status_text[:32] + "..."

                draw.text((10, 90), status_text, font=font, fill=self._black)

                # Mode indicator in top area
                mode_text = f"Mode: {status.get('mode', 'menu').upper()}"
                draw.text((10, 110), mode_text, font=fonts.Small, fill=self._black)

                # Activity indicators
                if status.get('pawning_active'):
                    draw.text((180, 110), "PAWNING", font=fonts.Small, fill=self._black)
                elif status.get('bluetooth_scanning'):
                    draw.text((180, 110), "BT_SCAN", font=fonts.Small, fill=self._black)
                else:
                    draw.text((180, 110), "IDLE", font=fonts.Small, fill=self._black)

        except Exception as e:
            logging.error(f"Error drawing status info: {e}")

    def _draw_activity_indicators(self, draw):
        """Draw activity indicators and stats"""
        try:
            if self._ui_controller:
                status = self._ui_controller.get_status()

                # Draw activity-specific information
                if status.get('pawning_active'):
                    # Show pawning stats if available
                    if hasattr(self._agent, '_handshakes'):
                        handshake_count = len(self._agent._handshakes)
                        draw.text((130, 110), f"HS:{handshake_count}", font=fonts.Small, fill=self._black)

                elif status.get('bluetooth_scanning'):
                    # Show Bluetooth device count
                    bt_count = status.get('bluetooth_devices', 0)
                    draw.text((130, 110), f"BT:{bt_count}", font=fonts.Small, fill=self._black)

                # Draw last action if available
                last_action = status.get('last_action')
                if last_action and len(last_action) > 0:
                    # Show in small text at bottom
                    action_text = last_action[:25] + "..." if len(last_action) > 25 else last_action
                    draw.text((10, 100), action_text, font=fonts.Small, fill=self._black)

        except Exception as e:
            logging.error(f"Error drawing activity indicators: {e}")

    def toggle_touch_zones(self):
        """Toggle visibility of touch zone borders"""
        self._touch_zones_visible = not self._touch_zones_visible
        self.update(force=True)

    def on_manual_mode(self, last_session):
        """Override manual mode display for interactive UI"""
        # Use our custom interactive display instead
        if self._ui_controller:
            status = self._ui_controller.get_status()
            if status['mode'] == 'menu':
                self._state.set('status', 'Manual mode - Touch to interact')
            else:
                self._state.set('status', status['status_message'])
        else:
            self._state.set('status', 'Interactive UI ready')

        self.update(force=True)

    def on_wifi_update(self, data):
        """Handle WiFi updates during pawning"""
        if self._ui_controller and self._ui_controller.get_status()['pawning_active']:
            # Update with WiFi scanning information
            if 'access_points' in data:
                ap_count = len(data['access_points'])
                self._state.set('status', f'Scanning: {ap_count} APs found')
            elif 'channel' in data:
                self._state.set('status', f'Channel: {data["channel"]}')

        super().on_wifi_update(data)

    def on_handshake(self, agent, filename, access_point, client_station):
        """Handle handshake capture events"""
        if self._ui_controller:
            self._state.set('status', f'Handshake captured: {access_point["hostname"]}')
            self.update(force=True)

        super().on_handshake(agent, filename, access_point, client_station)

    def on_peer_detected(self, peer):
        """Handle peer detection"""
        if self._ui_controller:
            self._state.set('status', f'Peer detected: {peer.name()}')
            self.update(force=True)

        super().on_peer_detected(peer)
