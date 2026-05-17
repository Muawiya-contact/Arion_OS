/*
 * Copyright 2010, Stephan Aßmus <superstippi@gmx.de>
 * Copyright 2020, Panagiotis "Ivory" Vasilopoulos <git@n0toose.net>
 * All rights reserved. Distributed under the terms of the MIT License.
 */


#include "BootPrompt.h"

#include <stdlib.h>

#include <Catalog.h>
#include <LaunchRoster.h>
#include <Locale.h>
#include <OS.h>
#include <Screen.h>
#include <String.h>
#include <View.h>
#include <Window.h>

#include <syscalls.h>


static int sExitValue;


namespace {


const rgb_color kSplashBlack = { 0, 0, 0, 255 };
const rgb_color kSplashBlue = { 0x4d, 0xa6, 0xff, 255 };
const rgb_color kSplashWhite = { 255, 255, 255, 255 };


enum SplashScreenKind {
	SPLASH_SCREEN_ONE,
	SPLASH_SCREEN_TWO,
};


class SplashView : public BView {
public:
	SplashView(BRect frame, SplashScreenKind kind)
		:
		BView(frame, "splash", B_FOLLOW_ALL, B_WILL_DRAW),
		kind(kind)
	{
		SetViewUIColor(B_PANEL_BACKGROUND_COLOR);
	}

	void Draw(BRect updateRect) override
	{
		FillRect(updateRect, kSplashBlack);

		BRect bounds(Bounds());
		const float centerX = bounds.left + bounds.Width() / 2.0f;
		const float centerY = bounds.top + bounds.Height() / 2.0f;

		switch (kind) {
			case SPLASH_SCREEN_ONE:
				_DrawScreenOne(centerX, centerY);
				break;

			case SPLASH_SCREEN_TWO:
				_DrawScreenTwo(centerX, centerY);
				break;
		}
	}

private:
	void _DrawCenteredString(const char* text, float centerX, float baseline,
		const BFont& font, const rgb_color& color)
	{
		SetFont(&font, B_FONT_ALL);
		SetHighColor(color);
		float textWidth = StringWidth(text);
		DrawString(text, BPoint(centerX - textWidth / 2.0f, baseline));
	}

	void _DrawScreenOne(float centerX, float centerY)
	{
		BFont font(be_bold_font);
		font.SetSize(32.0f);

		font_height metrics;
		font.GetHeight(&metrics);
		float lineHeight = metrics.ascent + metrics.descent + metrics.leading;
		float firstBaseline = centerY - lineHeight * 0.8f;
		float secondBaseline = firstBaseline + lineHeight + 10.0f;
		float separatorY = secondBaseline + metrics.descent + 18.0f;

		_DrawCenteredString("America kiya kehta tha?", centerX, firstBaseline,
			font, kSplashBlue);
		_DrawCenteredString("Kiya ho tum?", centerX, secondBaseline,
			font, kSplashBlue);

		SetHighColor(kSplashBlue);
		FillRect(BRect(centerX - 140.0f, separatorY, centerX + 140.0f,
			separatorY + 2.0f));
	}

	void _DrawScreenTwo(float centerX, float centerY)
	{
		BFont titleFont(be_bold_font);
		titleFont.SetSize(52.0f);

		BFont subFont(be_bold_font);
		subFont.SetSize(13.0f);

		BFont smallFont(be_bold_font);
		smallFont.SetSize(12.0f);

		font_height titleMetrics;
		titleFont.GetHeight(&titleMetrics);
		font_height subMetrics;
		subFont.GetHeight(&subMetrics);
		font_height smallMetrics;
		smallFont.GetHeight(&smallMetrics);

		float titleLineHeight = titleMetrics.ascent + titleMetrics.descent
			+ titleMetrics.leading;
		float subLineHeight = subMetrics.ascent + subMetrics.descent
			+ subMetrics.leading;
		float smallLineHeight = smallMetrics.ascent + smallMetrics.descent
			+ smallMetrics.leading;

		float titleBaseline = centerY - titleLineHeight * 0.9f;
		float subBaseline = titleBaseline + titleLineHeight + 16.0f;
		float separatorY = subBaseline + subLineHeight + 16.0f;
		float footerBaseline = separatorY + smallLineHeight + 18.0f;

		_DrawCenteredString("ARION OS", centerX, titleBaseline, titleFont,
			kSplashWhite);
		_DrawCenteredString("arion", centerX, subBaseline, subFont, kSplashBlue);

		SetHighColor(kSplashBlue);
		FillRect(BRect(centerX - 140.0f, separatorY, centerX + 140.0f,
			separatorY + 2.0f));

		_DrawCenteredString("POWERED BY CODING MOVES", centerX, footerBaseline,
			smallFont, kSplashBlue);
	}

	SplashScreenKind kind;
};


class SplashWindow : public BWindow {
public:
	SplashWindow(SplashScreenKind kind)
		:
		BWindow(BScreen(B_MAIN_SCREEN_ID).Frame(), "",
			B_NO_BORDER_WINDOW_LOOK, B_NORMAL_WINDOW_FEEL,
			B_NOT_MOVABLE | B_NOT_ZOOMABLE | B_NOT_MINIMIZABLE
				| B_NOT_RESIZABLE | B_AVOID_FOCUS | B_QUIT_ON_WINDOW_CLOSE
				| B_NOT_CLOSABLE),
		kind(kind)
	{
		SetBackgroundColor(kSplashBlack);
		AddChild(new SplashView(Bounds(), kind));
	}

	void ShowAndWait()
	{
		Show();
		Sync();
		snooze(3000000);
		Lock();
		Quit();
	}

private:
	SplashScreenKind kind;
};


static void
ShowBootSplashScreens()
{
	SplashWindow first(SPLASH_SCREEN_ONE);
	first.ShowAndWait();

	SplashWindow second(SPLASH_SCREEN_TWO);
	second.ShowAndWait();
}


} // namespace


int
main(int, char **)
{
	BootPromptApp app;
	app.Run();
	return sExitValue;
}


// #pragma mark -


const char* kAppSignature = "application/x-vnd.Haiku-FirstBootPrompt";
const char* kDeskbarSignature = "application/x-vnd.Be-TSKB";


BootPromptApp::BootPromptApp()
	:
	BApplication(kAppSignature)
{
}


void
BootPromptApp::MessageReceived(BMessage* message)
{
	switch (message->what) {
		// Booting the desktop or running the installer both result
		// in sending a B_QUIT_REQUESTED message that ultimately
		// closes the FirstBootPrompt window. However, according to
		// BootPromptWindow::QuitRequested(), if the BootPromptWindow
		// is not running on a desktop and the user decides to close
		// the window using the button, the user will be asked if
		// they wish to reboot their system.
		//
		// Asking that in the former scenarios would not make much
		// sense. "dont_reboot" explicitly states that the user does
		// not wish to reboot their system, which suppresses the
		// confirm box.
		case MSG_BOOT_DESKTOP:
		{
			BLaunchRoster().Target("desktop");
			sExitValue = 1;

			PostMessage(B_QUIT_REQUESTED);
			break;
		}
		case MSG_RUN_INSTALLER:
		{
			BLaunchRoster().Target("installer");
			sExitValue = 0;

			PostMessage(B_QUIT_REQUESTED);
			break;
		}
		case MSG_REBOOT_REQUESTED:
		{
			_kern_shutdown(true);
			sExitValue = -1;
			break;
		}

		default:
			BApplication::MessageReceived(message);
	}
}


void
BootPromptApp::ReadyToRun()
{
	ShowBootSplashScreens();

	// Prompt the user to select his preferred language.
	new BootPromptWindow();
}


bool
BootPromptApp::QuitRequested()
{
	// Override the default QuitRequested because we don't want to ask the
	// window. The window QuitRequested is used when closing the window, and
	// offers to reboot the system. When we get here, it means we got the
	// message from one of the Desktop/Installer buttons and we should just
	// exit.
	return true;
}
