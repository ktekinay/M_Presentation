# M_Presentation

Classes to help you present or demo a Xojo app on a second monitor.

## M\_Presentation Module

The module contains a number of control subclasses that will self-adjust their font size at runtime. Adjust the constant as needed and throw the control onto your window.

## Mirrored Window

Change your demo window's superclass to `MirroredWindowBase`. When you start your app, you will automatically get a "ghost" window that mirrors your window and a Scale window. Drag the ghost onto the projector or second monitor and use the scale to adjust its size. Demo on your main window and the ghost will reflect (almost) all changes.

### Limitations

The ghost will not show pop-up menu dropdowns, focus rings, or contextual menus.

## Who Did This

This project was created by Kem Tekinay (ktekinay at mactechnologies dot com). The scaler was added by Tim Parnell (timi at timi dot me).

With thanks to various Xojo developers who offered advice and suggestions at the Xojo Developer Conference.

## Release Notes

1.1 (April 27, 2018)

- Scale Window will include the name of the master window it is linked to.
- The cursor will show up on the ghost window as a red dot, or bullseye when clicked.
- Moved `MirroredWindowBase` out of the M\_Presentation module.

1.0 (April 26, 2018)

- Initial release.
