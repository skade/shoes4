module Shoes
  module Swt
    class ShoesKeyListener
      include ::Swt::KeyListener

      SPECIAL_KEY_NAMES = {}

      #Special keys
      %w[TAB PAGE_UP PAGE_DOWN HOME END F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12
         F13 F14 F15].each do|key|
        SPECIAL_KEY_NAMES[eval("::Swt::SWT::#{key}")] = key.downcase
      end
      %w[UP DOWN LEFT RIGHT].each do |key|
        SPECIAL_KEY_NAMES[eval("::Swt::SWT::ARROW_#{key}")] = key.downcase
      end

      SPECIAL_KEY_NAMES[::Swt::SWT::DEL] = "delete"
      SPECIAL_KEY_NAMES[::Swt::SWT::BS]  = "backspace"
      SPECIAL_KEY_NAMES[::Swt::SWT::ESC] = "escape"
      SPECIAL_KEY_NAMES[::Swt::SWT::CR]  = "\n"

      # modifier keys
      MODIFIER_KEYS = %w[CTRL SHIFT ALT CAPS_LOCK].map do |key|
        eval("::Swt::SWT::#{key}")
      end

      def initialize(blk)
        @block = blk
      end

      # NOTE: state_mask and key_code error for me so the java version is used
      def key_pressed(event)
        modifiers = modifier_keys(event)
        character = character_key(event)
        shoes_key_string = modifiers + character
        shoes_key_string = shoes_key_string.to_sym unless modifiers.empty?
        @block.call shoes_key_string unless character.empty?
      end

      def key_released(event)
      end

      private
      def modifier_keys(event)
        modifier_keys = ''
        modifier_keys += 'control_' if control?(event)
        modifier_keys += 'shift_' if shift?(event) && special_key?(event)
        modifier_keys += 'alt_' if alt?(event)
        modifier_keys
      end

      def alt?(event)
        modifier_key?(event, ::Swt::SWT::ALT)
      end

      def modifier_key?(event, key)
        (event.stateMask & key) == key
      end

      def shift?(event)
        modifier_key?(event, ::Swt::SWT::SHIFT)
      end

      def control?(event)
        modifier_key?(event, ::Swt::SWT::CTRL)
      end

      def character_key(event)
        return '' if current_key_is_modifier?(event)
        if special_key?(event)
          SPECIAL_KEY_NAMES[event.keyCode]
        elsif control?(event)
          character_for_control_keypress(event)
        else
          event.character.chr
        end
      end

      def character_for_control_keypress(event)
        character = event.keyCode.chr
        if shift?(event)
          character.upcase
        else
          character
        end
      end

      def special_key?(event)
        SPECIAL_KEY_NAMES[event.keyCode]
      end

      def current_key_is_modifier?(event)
        MODIFIER_KEYS.include? event.keyCode
      end
    end
  end
end