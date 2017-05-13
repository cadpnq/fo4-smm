# Settlement Menu Manager

If you're the author of a mod which adds things to the build menu with a script
it is pretty much a given that you've seen at least one bug report like this:

> I tried your mod and now my menus are gone! You broke my game! HELP!
>
> -- every user who forgot to run your uninstaller

Ok, maybe they didn't yell, but you get the idea. Sooner or later someone will
either not read the instructions or simply forget to follow them. At this point
they have two options:

* Reinstall your mod, run the uninstaller, and then disable it again.
* Install one of the menu fixer mods floating around and restart the game a
few times.

Kind of a pain, right?

Settlement Menu Manager (SMM) makes it all happen automagically. Once your
users have SMM installed all they will have to do (99% of the time) in order to
remove your mod (and any other mod using SMM) is take it out of their load
order.

## How to add SMM support to your mod:

TBD. This mod is still under construction. For now you can take a look at the
example plugin to see how things work.

Once you have done that you will want to add the following (or something like
it) to your mod description:

> This mod uses Settlement Menu Manager to add custom settlement menu
> categories. This means that you don't need to worry about running a special
> holotape/chem before you uninstall it: just remove it from your load order
> and you're done. This obviously also means that you will need to install SMM
> for this mod to work properly.

In addition to a notice, it would probably be a good idea for you to add SMM as
a requirement on your mod page.

## FAQ:

### User
**Q:** If I install SMM can I still use mods that set their own menus up?

**A:** Yes. SMM is designed to play nicely with other mods.

___

**Q:** If I install this does it mean that I can install/uninstall anything
without worrying about menus disappearing?

**A:** No, you will still need to run the uninstaller for any mod which is not
using SMM.

___

**Q:** If I want to stop using SMM can I just disable it? (Can SMM uninstall
itself automatically?)

**A:** No, it isn't actually possible for a mod to automatically clean up after
itself once it has been uninstalled. In order to properly uninstall SMM you will
have to activate the "Safe Mode" feature SMM has, save, close your game, and
then remove it from your load order. Obviously, uninstalling SMM will break any
mod that relies on SMM.

___

**Q:** I get a warning that says menu categories are limited to having 128
subcategories. What do I do?

**A1:** If you see the message when you uninstall a mod you should re-enable
whatever mod you uninstalled, start your game, activate "Safe Mode", save,
close your game, uninstall the mod again, and restart your game. This actually
happening is rather unlikely.

**A2:** If you see the message after you install a new mod it means that your
mods have tried to add more than 128 elements to some menu. You'll have to pick
which mods you actually want a only install them. This is also unlikely to
happen.

___

**Q:** What is "Safe Mode" and how do I enable it?

**A:** Safe Mode temporarily removes everything that SMM has added to the build
menu. The next time you load your game or open and close the build menu
everything will be re-added. To activate Safe Mode you have two options:
* Run the Settlement Menu Manager Holotape that was added to your inventory
when you installed SMM and select "Enter Safe Mode".
* Open your settlement build menu, navigate to the SMM category, and build the
Safe Mode Cube. Once built the cube will exit the build menu, enable Safe Mode,
and then delete itself.

___

**Q:** A non-SMM enabled mod broke my build menu. Can I use SMM to fix it?

**A:** Yes, either select the "Settlement Menu Rescue" option in the SMM
holotape or build the menu repair cube located in the SMM menu. It will scan
through the build menu and remove every invalid category/menu (without
clobbering the valid ones). (note: I have all the code for this, but I haven't
plugged it together yet.)

___

### Author
**Q:** Can't I just include your code in my mod and not depend on my users
installing SMM?

**A:** No! The whole point is having a seperate, always installed bit of code
that does everything. If each mod tried to do that they'd end up stomping all
over one another.

___

**Q:** How many menus can my mod add using SMM?

**A:** As many as you want; however, there is a global limit of 1024 custom
menu categories. I can increase this if necessary, but I can't imagine a
situation where you'd need more.
