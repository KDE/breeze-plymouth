/*
    Copyright (C) 2012-2016 Harald Sitter <sitter@kde.org>
    Copyright (C) 2009 Canonical Ltd.

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License as
    published by the Free Software Foundation; either version 3 of
    the License or any later version accepted by the membership of
    KDE e.V. (or its successor approved by the membership of KDE
    e.V.), which shall act as a proxy defined in Section 14 of
    version 3 of the license.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Written by: Alberto Milone <alberto.milone@canonical.com>

    Based on the example provided with the "script plugin" written by:
                Charlie Brej   <cbrej@cs.man.ac.uk>
*/

/**
 * 16bit debug override. Comment out to see what everything looks like on a 16bit
 * framebuffer/output.
 */
// Window.GetBitsPerPixel = fun() { return 4; };

// -------------------------------- Assets ---------------------------------- //

global.title.text = "@DISTRO_NAME@ @DISTRO_VERSION@";
global.defaults.font.default = "Noto Sans 12";
global.defaults.font.title = "Noto Sans 14";

global.assets = [];
if (Window.GetBitsPerPixel() == 4) {
    assets.logo          = "images/16bit/@DISTRO_LOGO@.logo.png";
    assets.text_input    = "images/16bit/text-input.png";

    assets.spinner_base  = "images/16bit/spinner";
} else {
    assets.logo          = "images/@DISTRO_LOGO@.logo.png";
    assets.text_input    = "images/text-input.png";

    assets.spinner_base  = "images/spinner";
}

// -------------------------------- Colors ---------------------------------- //
/**
 * General purpuse Color container to hold red, green, blue as any value
 * (real advisable).
 */
Color = fun(red, green, blue) {
    local.color = [];
    color.red = red;
    color.green = green;
    color.blue = blue;
    return color | global.Color;
} | [];

global.colors = [];
colors.black = Color(0, 0, 0);
colors.icon_blue = Color(0.1137, 0.6000, 0.9529);
colors.plasma_blue = Color(0.2392, 0.6824, 0.913);
colors.paper_white = Color(0.9882, 0.9882, 0.9882);
colors.charcoal_grey = Color(0.1922, 0.2118, 0.2314);
colors.cardboard_grey = Color(0.9373, 0.9412, 0.9451);

colors.neon_blue = Color(0.1608, 0.5020, 0.7255);
colors.neon_green = Color(0.1020, 0.7373, 0.6118);

global.palette = [];
palette.background.top = colors.@BACKGROUND_TOP_COLOR@;
palette.background.bottom = colors.@BACKGROUND_BOTTOM_COLOR@;
palette.text.normal = colors.cardboard_grey;
palette.text.tinted = colors.cardboard_grey;
palette.text.action = colors.cardboard_grey;
palette.text.contrast = colors.charcoal_grey; // Inverse essentially

/**
 * Helper overload to apply background colors from global.palette to the Window
 */
Window.ApplyBackgroundColors = fun() {
    Window.SetBackgroundTopColor(palette.background.top.red,
                                 palette.background.top.green,
                                 palette.background.top.blue);
    if (Window.GetBitsPerPixel() == 4) { // Force no gradient on 16bit.
        Window.SetBackgroundBottomColor(palette.background.top.red,
                                     palette.background.top.green,
                                     palette.background.top.blue);
    } else {
        Window.SetBackgroundBottomColor(palette.background.bottom.red,
                                        palette.background.bottom.green,
                                        palette.background.bottom.blue);
    }
};

// ------------------------------- Classes ---------------------------------- //

/**
 * class SpriteImage : Sprite {
 *     Image image,   # Image instance created by and for the Sprite
 *     int width,     # Image width
 *     int height,    # Image height
 *  };
 */

/**
 * General purpose sprite-image combination.
 * The type itself is a Sprite that has an image property through which the image
 * powering the sprite may be accessed.
 * Members of the sprite are only updated on initial creation, any future changes
 * to the actually used image need to be reflected manually
 */
SpriteImage = fun(asset) {
    local.sprite = Sprite();
    sprite.image = Image(asset);
    sprite.width = sprite.image.GetWidth();
    sprite.height = sprite.image.GetHeight();
    sprite.SetImage(sprite.image);
    return sprite | global.SpriteImage;
} | Sprite;

SpriteImage.SetSpriteImage = fun(image) {
    this.image = image;
    this.width = image.GetWidth();
    this.height = image.GetHeight();
    this.SetImage(this.image);
};

// --------------------------------- Debug ---------------------------------- //
// TODO: it may be handy to move all debug methods into a separate file
//   and configure_file them into the master script iff explicitly enabled.
//   This would reduce the script size and possibly eval time. Although
//   in the grand scheme of things I am not sure this script takes up a lot of
//   resources to begin with.
debugsprite = Sprite();
debugsprite_bottom = Sprite();
debugsprite_medium = Sprite();

// are we currently prompting for a password?
prompt_active = 0;

/**
 * General purpose function to create an image from a string.
 * \param text the string to print
 * \param color the color the string should use in the image
 * \returns Image containg the text
 */
fun WriteText(text, color, font) {
  if (!color) {
    color = palette.text.normal;
  }
  if (!font) {
    font = defaults.font.default;
  }
  return Image.Text(text, color.red, color.green, color.blue, 1,  font);
}

/** Create regular text image. \see WriteText */
fun ImageToText (text, font) {
    return WriteText(text, color, font);
}

String.ToImage = fun(color, font) {
  return WriteText(this, color, font);
};

/** Create tinted text image. \see WriteText */
fun ImageToTintedText (text) {
    return WriteText(text, palette.text.tinted);
}

/** Create action text image. \see WriteText */
fun ImageToActionText (text) {
    return WriteText(text, palette.text.action);
}

fun Debug(text) {
    debugsprite.SetImage(ImageToText (text));
    debugsprite.SetPosition(0, 0, 1);
}

fun DebugBottom(text) {
    debugsprite_bottom.SetImage(ImageToText(text));
    debugsprite_bottom.SetPosition(0, (Window.GetHeight (0) - 20), 1);
}

fun DebugMedium(text) {
    debugsprite_medium.SetImage(ImageToText (text));
    debugsprite_medium.SetPosition(0, (Window.GetHeight (0) - 60), 1);
}

/**
 * Debug helper to simulate something like a log on the right hand side of
 * the display. There is a global ActionStack which gets .Log("foo")'d into
 * which essentially prepends the string to an internal string buffer which
 * is then rendered into a sprite.
 * The buffer is not ever emptied so this basically is growing memory
 * consumption. And it's offset placing from the rigth side is also getting
 * increasingly wrong as the largest ever logged line dictates the offset.
 */
Logger = fun() {
    local.logger = [];
    local.logger.log = "";
    local.logger.sprite = Sprite();
    return logger | global.Logger;
} | [];

Logger.Log = fun(text) {
    log = text + "\n" + log;
    Print();
};

Logger.Print = fun() {
    sprite.SetImage(ImageToText(log));
    sprite.SetPosition(Window.GetMaxWidth() - sprite.GetImage().GetWidth() - 16, 0, 1);
};
global.logger = Logger();

/**
 * Calulates the Y of the label "box". That is, the top most point at which
 * we should put elements that are meant to go below the logo/spinner/whatevs
 * as to not overlap with the aforementioned. This includes message display,
 * password prompt and so forth.
 */
fun TextYOffset() {
    // Put the 1st line below the logo.
    local.y = spin.GetY() + spin.GetHeight();
    local.text_height = first_line_height * 7.5;
    // The maximum Y we may end at, if we exceed this we'll try to scoot up
    // a bit. This includes the Window offset itself as we position ourselves
    // relative to the Spinner which is relative to the Logo which is relative
    // to the center of the window TAKING INTO ACCOUNT the y offset of the
    // window!
    local.max_y = Window.GetHeight() + Window.GetY();

    if (y + text_height > max_y) {
        y = max_y - text_height;
    } else {
        y = y + ((max_y - y - text_height) / 2);
    }

    // This basically undoes whatever went on above, to a degree...
    // If the y would overlap with the Spinner (bottom most element of the
    // static cruft) we move it further down so that at least half a line of
    // space is between the spinner and our y.
    if (y < spin.GetY() + spin.GetHeight() + first_line_height / 2) {
        y = spin.GetY() + spin.GetHeight() + first_line_height / 2;
    }

    return y;
}

Window.GetMaxWidth = fun() {
    width = 0;
    for (i = 0; Window.GetWidth(i); i++) {
        width = Math.Max(width, Window.GetWidth(i));
    }
    return width;
};

Window.GetMaxHeight = fun() {
    height = 0;
    for (i = 0; Window.GetHeight(i); i++) {
        height = Math.Max(height, Window.GetHeight(i));
    }
    return height;
};

// --------------------------------- String --------------------------------- //
# This is the equivalent for strstr()
fun StringString(string, substring) {
    start = 0;
    while (String(string).CharAt (start)) {
        walk = 0;
        while (String(substring).CharAt (walk) == String(string).CharAt (start + walk) ) {
            walk++;
            if (!String(substring).CharAt (walk)) return start;
        }
        start++;
    }

    return NULL;
}

fun StringLength (string) {
    index = 0;
    while (String(string).CharAt(index))
        index++;
    return index;
}

// String.Length = fun(string) {
//     index = 0;
//     while (String(string).CharAt(index))
//         index++;
//     return index;
// };

fun StringCopy (source, beginning, end) {
    local.destination = "";
    for (index = beginning;
         (((end == NULL) || (index <= end) ) && (String(source).CharAt(index)));
         index++) {
        local.destination += String(source).CharAt(index);
    }

    return local.destination;
}

fun StringReplace (source, pattern, replacement) {
    local.found = StringString(source, pattern);
    if (local.found == NULL) {
        return source;
    }

    local.new_string = StringCopy (source, 0, local.found - 1) +
                       replacement +
                       StringCopy (source, local.found + StringLength(pattern), NULL);

    return local.new_string;
}

# it makes sense to use it only for
# numbers up to 100
fun StringToInteger (str) {
    int = -1;
    for (i=0; i<=100; i++) {
        if (i+"" == str) {
            int = i;
            break;
        }
    }
    return int;
}

// ------------------------------ Background -------------------------------- //
Window.ApplyBackgroundColors();
global.backgroundApplied = false;

// --------------------------------- Logo ----------------------------------- //

Logo = fun() {
    local.logo = SpriteImage(assets.logo);
    logo.x = Window.GetX() + Window.GetWidth() / 2 - logo.width / 2;
    logo.y = Window.GetY() + Window.GetHeight() / 2 - logo.height / 2;
    logo.z = 1000;
    logo.SetPosition(logo.x, logo.y, logo.z);

    logo.name = Sprite(title.text.ToImage(NULL, defaults.font.title));
    logo.name.x = Window.GetX() + Window.GetWidth() / 2 - logo.name.GetImage().GetWidth() / 2;
    logo.name.y = logo.y + logo.height + logo.name.GetImage().GetHeight() / 2;
    logo.name.z = logo.z;
    logo.name.SetPosition(logo.name.x, logo.name.y, logo.z);

    logo.height = logo.height + logo.name.GetImage().GetHeight() ;

    return logo | global.Logo;
} | SpriteImage;

Logo.SetOpacity_ = fun(o) {
    o = Math.Clamp(o, 0.0, 1.0);
    this.SetOpacity(o);
    this.name.SetOpacity(o);
};

logo = Logo();
logo.SetOpacity_(0);


// ----------------------------- Busy Animation ----------------------------- //

Spinner = fun() {
    // FIXME: try to use this=
    spinner = global.Spinner | [];
    spinner.count = 360;
    spinner.current_idx = 0;
    spinner.last_time = 0;
    spinner.steps = 10.0; // We render degrees in increments of 10 to save disk.
    spinner.duration = 1.5; // Seconds per rotation.
    for (i = 0; i <= spinner.count; ++i) {
        if (i % spinner.steps != 0) {
            continue;
        }
        spinner[i] = SpriteImage(assets.spinner_base + "/spinner" + i + ".png");
        center_offset = (logo.width / 2) - (spinner[i].width / 2);
        top_offset = logo.height + spinner[i].height;
        spinner[i].SetPosition(logo.GetX() + center_offset, logo.GetY() + top_offset, logo.GetZ());
        spinner[i].SetOpacity(0);
    }
    return spinner;
} | [];

Spinner.Animate = fun(time) {
    degrees = Math.Int(((2 * Math.Pi / duration) * time) * (180 / Math.Pi));
    new = degrees % count;
    old = current_idx;
    if (Math.Int(new) < Math.Int((old + steps) % count)) {
        // Every $steps degrees we can render a frame, all others we skip.
        return;
    }
    // We set a second new which is now a correct index bump by coercing it
    // into a multiple of 10.
    new = Math.Int(new / steps) * steps;
    // Debug("going from " + old + " to " + new);
    // dps = time - last_time;
    // DebugMedium("dps " + dps*35);
    // last_time = time;
    this[old].SetOpacity(0);
    this[new].SetOpacity(1);
    current_idx = new;
    return this;
};

Spinner.GetY = fun() {
    return this[0].GetY();
};

Spinner.GetHeight = fun() {
    return this[0].height;
};

global.spin = Spinner();

// ---------------------------- State & Spacing ----------------------------- //

message_notification[0].image = ImageToTintedText ("");
message_notification[1].image = ImageToTintedText ("");
fsck_notification.image = ImageToActionText ("");

status = "normal";

// use a fixed string with ascending and descending stems to calibrate the
// bounding box for the first message, so the messages below don't move up
// and down according to *their* height.
first_line_height = ImageToTintedText ("AfpqtM").GetHeight();

// if the user has a 640x480 or 800x600 display, we can't quite fit everything
// (including passphrase prompts) with the target spacing, so scoot the text up
// a bit if needed.
top_of_the_text = TextYOffset();

// ----------------------------- Boot Progress ------------------------------ //

/**
 * Implement boot progress callback
 * \param time time elapsed since boot start (real, seconds)
 * \param progress boot progress in % (real 0.0 to 1.0)
 */
fun boot_progress_cb(time, progress) {
    spin.Animate(time);
    logo.SetOpacity_(time * 2.0);
}
Plymouth.SetBootProgressFunction (boot_progress_cb);

#-----------------------------------------Label utility functions---------------------

# label should be either a string or NULL
# Images for n lines will be created and returned as items of the
# message_label array
#
fun get_message_label (label, is_fake, is_action_line) {
    # Debug("Get Label position");

    if (is_fake)
        # Create a fake label so as to get the y coordinate of
        # a standard-length label.
        local.message_image = ImageToTintedText ("This is a fake message");
    else
        local.message_image = (is_action_line) && ImageToActionText (label) || ImageToTintedText (label);

    local.message_label = [];
    message_label.width = message_image.GetWidth ();
    message_label.height = message_image.GetHeight ();

    # Center the line horizontally
    message_label.x = Window.GetX () + Window.GetWidth () / 2 - message_label.width / 2;

    message_label.y = top_of_the_text + first_line_height/2;

    # Put the 2nd line below the fsck line
    if (is_action_line) {
        local.fsck_label.y = message_label.y + (first_line_height + first_line_height / 2);
        message_label.y = local.fsck_label.y + (first_line_height * 2);
    }

    # Debug("action label x = " + message_label.x + " y = " + message_label.y );

#    message_debug = "msg_x = " + message_label.x + " msg_y = " + message_label.y +
#                    "msg_width = " + message_label.width + " msg_height = " +
#                    message_label.height + " message = " + label;
#    Debug(message_debug);

    return message_label;

}

# Create an fsck label and/or get its position
fun get_fsck_label (label, is_fake) {
    # Debug("Get Label position");
    local.fsck_label = global.progress_label;

    if (is_fake)
        fsck_label.image = ImageToTintedText ("This is a fake message");
    else
        fsck_label.image = ImageToTintedText (label);

    fsck_label.width = fsck_label.image.GetWidth ();
    fsck_label.height = fsck_label.image.GetHeight ();

    # Centre the label horizontally
    fsck_label.x = Window.GetX () + Window.GetWidth () / 2 - fsck_label.width / 2;

    local.first_label = get_message_label (label, 1, 0);

    # Place the label below the 1st message line
    fsck_label.y = local.first_label.y + local.first_label.height + first_line_height / 2;

#    message_debug = "msg_x = " + fsck_label.x + " msg_y = " + fsck_label.y +
#                    "msg_width = " + fsck_label.width + " msg_height = " +
#                    fsck_label.height + " message = " + label;
#    Debug(message_debug);

    return fsck_label;
}

#-----------------------------------------Message stuff --------------------------------
#

# Set up a message label
#
# NOTE: this is called when doing something like 'plymouth message "hello world"'
#
fun setup_message (message_text, x, y, z, index) {
    # Debug("Message setup");
    global.message_notification[index].image =
        (index) && ImageToActionText (message_text) || ImageToTintedText (message_text);

    # Set up the text message, if any
    message_notification[index].x = x;
    message_notification[index].y = y;
    message_notification[index].z = z;

    message_notification[index].sprite = Sprite ();
    message_notification[index].sprite.SetImage (message_notification[index].image);
    message_notification[index].sprite.SetX (message_notification[index].x);
    message_notification[index].sprite.SetY (message_notification[index].y);
    message_notification[index].sprite.SetZ (message_notification[index].z);

}

fun show_message (index) {
    if (global.message_notification[index].sprite) global.message_notification[index].sprite.SetOpacity(1);
}

fun hide_message (index) {
    if (global.message_notification[index].sprite) global.message_notification[index].sprite.SetOpacity(0);
}

# the callback function is called when new message should be displayed.
# First arg is message to display.
fun message_callback (message)
{
    // DebugMedium("Message callback " + message);
    is_fake = 0;
    if (!message || (message == "")) is_fake = 1;

    local.substring = "keys:";

    # Look for the "keys:" prefix
    local.keys = StringString(message, local.substring);

    local.is_action_line = (keys != NULL);
    #Debug("keys " + local.keys + " substring length = " + StringLength(local.substring);

    # Get the message without the "keys:" prefix
    if (keys != NULL)
        message = StringCopy (message, keys + StringLength(local.substring), NULL);

    // Get the message without the "fsckd-cancel-msg" prefix as we don't support i18n
    substring = "fsckd-cancel-msg:";
    keys = StringString(message, substring);
    if (keys != NULL)
        message = StringCopy(message, keys + StringLength(substring), NULL);

    local.label.is_fake = is_fake;
    label = get_message_label(message, is_fake, is_action_line);
    label.z = 10000;

    setup_message (message, label.x, label.y, label.z, is_action_line);
    if (prompt_active && local.is_action_line)
        hide_message (is_action_line);
    else
        show_message (is_action_line);
}
Plymouth.SetMessageFunction (message_callback);


#-----------------------------------------Display Password stuff -----------------------
#

fun password_dialog_setup (message_label) {
    # Debug("Password dialog setup");

    local.bullet_image = WriteText("•", palette.text.contrast);
    local.entry = [];
    entry.image = Image (assets.text_input);

    # Hide the normal labels
    prompt_active = 1;
    if (message_notification[1].sprite) hide_message (1);

    # Set the prompt label
    label = get_message_label(message_label, 0, 1);
    label.z = 10000;

    setup_message (message_label, label.x, label.y, label.z, 2);
    show_message (2);

    # Set up the text entry which contains the bullets
    entry.sprite = Sprite ();
    entry.sprite.SetImage (entry.image);

    # Centre the box horizontally
    entry.x = Window.GetX () + Window.GetWidth () / 2 - entry.image.GetWidth () / 2;

    # Put the entry below the second label.
    entry.y = message_notification[2].y + label.height + entry.image.GetHeight() / 2;

    #Debug ("entry x = " + entry.x + ", y = " + entry.y);
    entry.z = 10000;
    entry.sprite.SetX (entry.x);
    entry.sprite.SetY (entry.y);
    entry.sprite.SetZ (entry.z);

    global.password_dialog = local;
}

fun password_dialog_opacity (opacity) {
    # Debug("Password dialog opacity");
    global.password_dialog.opacity = opacity;
    local = global.password_dialog;

    # You can make the box translucent with a float
    # entry.sprite.SetOpacity (0.3);
    entry.sprite.SetOpacity (opacity);
    label.sprite.SetOpacity (opacity);

    if (bullets) {
        for (index = 0; bullets[index]; index++) {
            bullets[index].sprite.SetOpacity (opacity);
        }
    }
}


# The callback function is called when the display should display a password dialog.
# First arg is prompt string, the second is the number of bullets.
fun display_password_callback (prompt, bullets) {
    global.status = "password";
    if (!global.password_dialog)
        password_dialog_setup(prompt);
    password_dialog_opacity (1);
    bullet_width = password_dialog.bullet_image.GetWidth();
    bullet_y = password_dialog.entry.y +
               password_dialog.entry.image.GetHeight () / 2 -
               password_dialog.bullet_image.GetHeight () / 2;
    margin = bullet_width;
    spaces = Math.Int((password_dialog.entry.image.GetWidth () - (margin * 2)) / bullet_width);
    bullets_area.width = (margin * 2) + (spaces * bullet_width);
    bullets_area.x = Window.GetX () + Window.GetWidth () / 2 - bullets_area.width / 2;
    if (bullets > spaces)
        bullets = spaces;
    for (index = 0; password_dialog.bullets[index] || index < bullets; index++){
        if (!password_dialog.bullets[index]) {
            password_dialog.bullets[index].sprite = Sprite();
            password_dialog.bullets[index].sprite.SetImage (password_dialog.bullet_image);
            password_dialog.bullets[index].x = bullets_area.x + margin + index * bullet_width;
            password_dialog.bullets[index].sprite.SetX (password_dialog.bullets[index].x);
            password_dialog.bullets[index].y = bullet_y;
            password_dialog.bullets[index].sprite.SetY (password_dialog.bullets[index].y);
            password_dialog.bullets[index].z = password_dialog.entry.z + 1;
            password_dialog.bullets[index].sprite.SetZ (password_dialog.bullets[index].z);
        }

        password_dialog.bullets[index].sprite.SetOpacity (0);

        if (index < bullets) {
            password_dialog.bullets[index].sprite.SetOpacity (1);
        }
    }
}
Plymouth.SetDisplayPasswordFunction(display_password_callback);

#----------------------------------------- FSCK Counter --------------------------------

# Initialise the counter
fun init_fsck_count () {
    # The number of fsck checks in this cycle
    global.counter.total = 0;
    # The number of fsck checks already performed + the current one
    global.counter.current = 1;
    # The previous fsck
    global.counter.last = 0;
}

# Increase the total counter
fun increase_fsck_count () {
    global.counter.total++;
}

fun increase_current_fsck_count () {
    global.counter.last = global.counter.current++;
}

# Clear the counter
fun clear_fsck_count () {
    global.counter = NULL;
    init_fsck_count ();
}

// ----------------------------------------- Progress Label ------------------------------


# Change the opacity level of a progress label
#
# opacity = 1 -> show
# opacity = 0 -> hide
# opacity = 0.3 (or any other float) -> translucent
#
fun set_progress_label_opacity (opacity) {
    # the label
    progress_label.sprite.SetOpacity (opacity);

    # Make the slot available again when hiding the bar
    # So that another bar can take its place
    if (opacity == 0) {
        progress_label.is_available = 1;
        progress_label.device = "";
    }
}

# Set up a new Progress Bar
#
# TODO: Make it possible to reuse (rather than recreate) a bar
#       if .is_available = 1. Ideally this would just reset the
#       label, the associated
#       device and the image size of the sprite.

fun init_progress_label (device, status_string) {
    # Make the slot unavailable
    global.progress_label.is_available = 0;
    progress_label.progress = 0;
    progress_label.device = device;
    progress_label.status_string = status_string;
}

# See if the progress label is keeping track of the fsck
# of "device"
#
fun device_has_progress_label (device) {
    #DebugBottom ("label device = " + progress_label.device + " checking device " + device);
    return (progress_label.device == device);
}

# Update the Progress bar which corresponds to index
#
fun update_progress_label (progress) {
    # If progress is NULL then we just refresh the label.
    # This happens when only counter.total has changed.
    if (progress != NULL) {
        progress_label.progress = progress;

        #Debug("device " + progress_label.device + " progress " + progress);

        # If progress >= 100% hide the label and make it available again
        if (progress >= 100) {
            set_progress_label_opacity (0);

            # See if we any other fsck check is complete
            # and, if so, hide the progress bars and the labels
            on_fsck_completed ();

            return 0;
        }
    }
    # Update progress label here
    #
    # FIXME: the queue logic from this theme should really be moved into mountall
    # instead of using string replacement to deal with localised strings.
    label = StringReplace (progress_label.status_string[0], "%1$d", global.counter.current);
    label = StringReplace (label, "%2$d",  global.counter.total);
    label = StringReplace (label, "%3$d",  progress_label.progress);
    label = StringReplace (label, "%%",  "%");

    progress_label = get_fsck_label (label, 0);
    #progress_label.progress = progress;

    progress_label.sprite = Sprite (progress_label.image);

    # Set up the bar
    progress_label.sprite.SetPosition(progress_label.x, progress_label.y, 1);

    set_progress_label_opacity (1);

}

# Refresh the label so as to update counters
fun refresh_progress_label () {
    update_progress_label (NULL);
}

#----------------------------------------- FSCK Queue ----------------------------------

# Initialise the fsck queue
fun init_queue () {
    global.fsck_queue[0].device;
    global.fsck_queue[0].progress;
    global.fsck_queue.counter = 0;
    global.fsck_queue.biggest_item = 0;
}

fun clear_queue () {
    global.fsck_queue = NULL;
    init_queue ();
}

# Return either the device index in the queue or -1
fun queue_look_up_by_device (device) {
    for (i=0; i <= fsck_queue.biggest_item; i++) {
        if ((fsck_queue[i]) && (fsck_queue[i].device == device))
            return i;
    }
    return -1;
}

# Keep track of an fsck process in the queue
fun add_fsck_to_queue (device, progress) {
    # Look for an empty slot in the queue
    for (i=0; global.fsck_queue[i].device; i++) {
        continue;
    }
    local.index = i;

    # Set device and progress
    global.fsck_queue[local.index].device = device;
    global.fsck_queue[local.index].progress = progress;

    # Increase the queue counter
    global.fsck_queue.counter++;

    # Update the max index of the array for iterations
    if (local.index > global.fsck_queue.biggest_item)
        global.fsck_queue.biggest_item = local.index;

    #DebugMedium ("Adding " + device + " at " + local.index);
}

fun is_queue_empty () {
    return (fsck_queue.counter == 0);
}

fun is_progress_label_available () {
    return (progress_label.is_available == 1);
}


# This should cover the case in which the fsck checks in
# the queue are completed before the ones showed in the
# progress label
fun on_queued_fsck_completed () {
    if (!is_queue_empty ())
        return;

    # Hide the extra label, if any
    #if (progress_bar.extra_label.sprite)
    #    progress_bar.extra_label.sprite.SetOpacity(0);
}

fun remove_fsck_from_queue (index) {
    # Free memory which was previously allocated for
    # device and progress
    global.fsck_queue[index].device = NULL;
    global.fsck_queue[index].progress = NULL;

    # Decrease the queue counter
    global.fsck_queue.counter--;

    # See if there are other processes in the queue
    # if not, clear the extra_label
    on_queued_fsck_completed ();
}

fun on_fsck_completed () {
    # We have moved on to tracking the next fsck
    increase_current_fsck_count ();

    if (!is_progress_label_available ())
        return;

    if (!is_queue_empty ())
        return;

    # Hide the progress label
    if (progress_label.sprite)
        progress_label.sprite.SetOpacity (0);

    # Clear the queue
    clear_queue ();

    # Clear the fsck counter
    clear_fsck_count ();
}

# Update an fsck process that we keep track of in the queue
fun update_progress_in_queue (index, device, progress) {
    # If the fsck is complete, remove it from the queue
    if (progress >= 100) {
        remove_fsck_from_queue (index);
        on_queued_fsck_completed ();
        return;
    }

    global.fsck_queue[index].device = device;
    global.fsck_queue[index].progress = progress;

}

# TODO: Move it to some function
# Create an empty queue
#init_queue ();


#----------------------------------------- FSCK Functions ------------------------------


# Either add a new bar for fsck checks or update an existing bar
#
# NOTE: no more than "progress_bar.max_number" bars are allowed
#
fun fsck_check (device, progress, status_string) {

    # The 1st time this will take place
    if (!global.progress_label) {
        # Increase the fsck counter
        increase_fsck_count ();

        # Set up a new label for the check
        init_progress_label (device, status_string);
        update_progress_label (progress);

        return;
    }


    if (device_has_progress_label (device)) {
        // Update the progress of the existing label
        update_progress_label (progress);
    }
    else {
        //  See if there's already a slot in the queue for the device
        local.queue_device_index = queue_look_up_by_device(device);

        // See if the progress_label is available
        if (progress_label.is_available) {
            # If the fsck check for the device was in the queue, then
            # remove it from the queue
            if (local.queue_device_index >= 0) {
                remove_fsck_from_queue (index);
            }
            else {
                # Increase the fsck counter
                increase_fsck_count ();
            }

            // Set up a new label for the check
            init_progress_label (device, status_string);
            update_progress_label (progress);

        }
        # If the progress_label is not available
        else {

            # If the fsck check for the device is already in the queue
            # just update its progress in the queue
            if (local.queue_device_index >= 0) {
                #DebugMedium("Updating queue at " + local.queue_device_index + " for device " + device);
                update_progress_in_queue (local.queue_device_index, device, progress);
            }
            # Otherwise add the check to the queue
            else {
                #DebugMedium("Adding device " + device + " to queue at " + local.queue_device_index);
                add_fsck_to_queue (device, progress);

                # Increase the fsck counter
                increase_fsck_count ();

                refresh_progress_label ();
            }

        }
    }
}


#-----------------------------------------Update Status stuff --------------------------
#
# The update_status_callback is what we can use to pass plymouth whatever we want so
# as to make use of features which are available only in this program (as opposed to
# being available for any theme for the script plugin).
#
# Example:
#
#   Thanks to the current implementation, some scripts can call "plymouth --update=fsck:sda1:40"
#   and this program will know that 1) we're performing and fsck check, 2) we're checking sda1,
#   3) the program should set the label progress to 40%
#
# Other features can be easily added by parsing the string that we pass plymouth with "--update"
#
fun update_status_callback (status) {
    // Debug(" STATUS:" + status);
    if (!status) return;

    string_it = 0;
    update_strings[string_it] = "";

    for (i=0; (String(status).CharAt(i) != ""); i++) {
        local.temp_char = String(status).CharAt(i);
        if (temp_char != ":")
            update_strings[string_it] += temp_char;
        else
            update_strings[++string_it] = "";
    }

    // Let's assume that we're dealing with these strings fsck:sda1:40
    if ((string_it >= 2) && (update_strings[0] == "fsck")) {

        device = update_strings[1];
        progress = update_strings[2];
        status_string[0] = update_strings[3]; # "Checking disk %1$d of %2$d (%3$d %% complete)"
        if (!status_string[0])
            status_string[0] = "Checking disk %1$d of %2$d (%3$d %% complete)";

        if ((device != "") && (progress != "")) {
            progress = StringToInteger (progress);

            # Make sure that the fsck_queue is initialised
            if (!global.fsck_queue)
                init_queue ();

            # Make sure that the fsck counter is initialised
            if (!global.counter)
                init_fsck_count ();

#            if (!global.progress_bar.extra_label.sprite)
#                create_extra_fsck_label ();

            # Keep track of the fsck check
            fsck_check (device, progress, status_string);
        }

    }

    # systemd-fsckd pass fsckd:<number_devices>:<progress>:<l10n_string>
    if (update_strings[0] == "fsckd") {
        number_devices = StringToInteger(update_strings[1]);

        if (number_devices > 0) {
            label = update_strings[3];

            progress_label = get_fsck_label (label, 0);
            progress_label.sprite = Sprite (progress_label.image);
            progress_label.sprite.SetPosition(progress_label.x, progress_label.y, 1);
            progress_label.sprite.SetOpacity (1);
        } else {
            if (progress_label.sprite)
                progress_label.sprite.SetOpacity (0);
        }
    }

}
Plymouth.SetUpdateStatusFunction (update_status_callback);

/**
 * Calling Plymouth.SetRefreshFunction with a function will set that function to be
 * called up to 50 times every second, e.g.
 *
 * NOTE: if a refresh function is not set, Plymouth doesn't seem to be able to update
 *      the screen correctly
 */
fun refresh_callback() {
    // With some nvidia systems when using the script theme the initial
    // background drawing happens too soon, so we do an additional "fallback"
    // draw run when the first refresh callback arrives. This should make sure
    // that we always have a background drawn.
    if (!global.backgroundApplied) {
        global.backgroundApplied = true;
        Window.ApplyBackgroundColors();
    }
}
Plymouth.SetRefreshFunction(refresh_callback);

/**
 * The callback function is called when the display should return to normal
 */
fun display_normal_callback() {
    global.status = "normal";
    if (global.password_dialog) {
        password_dialog_opacity (0);
        global.password_dialog = NULL;
        if (message_notification[2].sprite) hide_message(2);
        prompt_active = 0;
    }

    if (message_notification[1].sprite)
        show_message (1);
}
Plymouth.SetDisplayNormalFunction (display_normal_callback);

/**
 * Switch to final state.
 */
fun quit_callback() {
  logo.SetOpacity_(0);
}
Plymouth.SetQuitFunction(quit_callback);

// kate: space-indent on; indent-width 2; mixedindent off; indent-mode cstyle; hl JavaScript;
