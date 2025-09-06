
2. Verify touchscreen detection:
   ```bash
   sudo evtest
   # Select your touch device and test touches
   ```

3. Check logs:
   ```bash
   tail -f /var/log/pwnagotchi.log | grep -i touch
   ```

### Display Issues
1. Verify display type in config
2. Check display connections
3. Test with regular pwnagotchi mode first

### Bluetooth Problems
1. Ensure Bluetooth is enabled:
   ```bash
   sudo systemctl enable bluetooth
   sudo systemctl start bluetooth
   ```

2. Check bluetoothctl availability:
   ```bash
   which bluetoothctl
   sudo bluetoothctl scan on
   ```

## Development

### Adding Custom Touch Actions
Extend the `UIController` class in `pwnagotchi/ui/controller.py`:

```python
def _on_custom_touch(self):
    # Your custom action here
    pass

# Register in _setup_touch_callbacks()
self._touch_handler.register_callback('custom_zone', self._on_custom_touch)
```

### Custom Display Layouts
Modify touch zones in `pwnagotchi/ui/touchscreen.py`:

```python
self._touch_zones = {
    'custom_button': {'x': (0, 50), 'y': (0, 30)},
    # Add your custom zones
}
```

## License

This enhancement maintains the original GPL3 license of the Pwnagotchi project.

## Contributing

1. Test thoroughly on your hardware setup
2. Follow the existing code style
3. Document any new features
4. Submit pull requests with clear descriptions

## Credits

- Original Pwnagotchi project by [@evilsocket](https://twitter.com/evilsocket)
- Current maintenance by [jayofelony team](https://github.com/jayofelony/pwnagotchi)
- Interactive UI enhancement for touchscreen control
