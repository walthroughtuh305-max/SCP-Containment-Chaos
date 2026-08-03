using namespace CB;
using namespace B3D;

#include "events.as"

// TIMERS
float timervalueset, timervalue = 999999;

// Seconds, used for custom timer sets (only supports 5, 10, 15, 20, 30, 40, 50, and 60. Might be freely customizable in the future)
// seconds = 0: Deafult (depends on OtherFactors), more than 0 means the amount of seconds the timer should be set to. This is only applied when the difficulty is set to Customizable.
int seconds, secondssetting /* used for selecting the seconds */;

// VALUES
int RandStart = 1;
int RandEnd = 17;

float CurveAngle(float destination, float current, float smooth) {
    float diff = destination - current;
    while (diff < -180.0f) diff += 360.0f;
    while (diff >  180.0f) diff -= 360.0f;
    return current + (diff / smooth);
}

CB::Sound buzz;
Image TimerIcon, TimerMeter;

void Hook_Initialize() {
    buzz = CB::Sound::Load("SFX\\Radio\\Buzz.ogg");
    TimerIcon = LoadImageHUDScaled("GFX\\TimerIcon.png");
    TimerMeter = LoadImageHUDScaled("GFX\\TimerMeter.png");
}

bool Hook_LoadEntities() {
    timervalue = 999999;
    return false;
}

class etimer {
    int id;
    float timeremaining;
    float totalduration;

    etimer(int id, float duration) {
        this.id = id;
        this.timeremaining = duration;
        this.totalduration = duration;
    }
}

array<etimer@> activeetimers;

// Create and start a new etimer
void StartTimer(int id, float duration) {
    etimer newtimer(id, duration);
    activeetimers.InsertLast(@newtimer);
}

void Hook_Update() {
    if (Menu::IsMainMenuOpen) return;

    // Setup values for other difficulty factors, or custom
    if (Difficulty::Current.Other == Difficulty::OtherFactors::Easy && seconds == 0 && Menu::IsAnyOpen() == false) {
        timervalueset = 70 * 30;
    } else if (Difficulty::Current.Other == Difficulty::OtherFactors::Normal && seconds == 0 && Menu::IsAnyOpen() == false) {
        timervalueset = 70 * 20;
    } else if (Difficulty::Current.Other == Difficulty::OtherFactors::Hard && seconds == 0 && Menu::IsAnyOpen() == false) {
        timervalueset = 70 * 10;
    } else if (Difficulty::Current.Customizable == true && seconds > 0 && Menu::IsAnyOpen() == false) {
        timervalueset = 70 * seconds;
    }

    // Timer logic
    if (timervalue > 0) {
        timervalue = timervalue - FPSFactor;
    } 
    if (timervalue <= 0) {
        buzz.Play();
        Hook_ChaosEvent(Rand(RandStart, RandEnd));
        timervalue = timervalueset;
    }
    if (timervalue > timervalueset) {
        timervalue = timervalueset;
    }

    for (uint i = 0; i < activeetimers.Length; i++) {
        activeetimers[i].timeremaining -= FPSFactor;

        if (activeetimers[i].timeremaining <= 0) {
            int idfinished = activeetimers[i].id;
            activeetimers.RemoveAt(i);
            i--; 
            OnEventTimerComplete(idfinished);
        }
    }
}

bool Hook_DrawHUD() {
    // HUD::EndY - 135 * HUD::Scale = Timer Bar y-axis
    // HUD::EndY - 95 * HUD::Scale = Blink Bar y-axis
    // HUD::EndY - 55 * HUD::Scale = Sprint Bar y-axis
    int x = HUD::StartX + 80 * HUD::Scale;
    int y = HUD::EndY - 135 * HUD::Scale;
    int width = 204 * HUD::Scale;
    Menu::DrawBar(TimerMeter, x, y, width, 1 - (timervalueset - timervalue) / timervalueset, false);
    SetColor(255, 255, 255);
    Rect(x - 50 * HUD::Scale - 1, y - 1, 30 * HUD::Scale + 2, 30 * HUD::Scale + 2);
    TimerIcon.Draw(x - 50 * HUD::Scale, y);
    return false;
}

bool Hook_MouseLook() {
	// FIX: Cameras not moving with the player when returned true
    bool CollidedFloor = false;
    for (int i = 1; i <= CB::Player::Head.CountCollisions(); i++) {
        if (CB::Player::Head.CollisionY(i) < CB::Player::Head.GetY() - 0.01f) CollidedFloor = true;
    }

    if (CollidedFloor == true) {
        CB::Player::HeadDropSpeed = 0;
    } else if (FakeDeathAnim > -1) {
        if (FakeDeathAnim == 0) {
            CB::Player::Head.Move(0, 0, CB::Player::HeadDropSpeed);
            CB::Player::Head.Rotate(CurveAngle(-90.0f, CB::Player::Head.GetPitch(), 20.0f), CB::Player::Head.GetYaw(), CB::Player::Head.GetRoll());
            CB::Player::Camera.Rotate(CurveAngle(CB::Player::Head.GetPitch() - 40.0f, CB::Player::Camera.GetPitch(), 40.0f), CB::Player::Camera.GetYaw(), CB::Player::Camera.GetRoll());
        } else if (FakeDeathAnim == 1) {
            CB::Player::Head.Move(0, 0, -CB::Player::HeadDropSpeed);
            CB::Player::Head.Rotate(CurveAngle(90.0f, CB::Player::Head.GetPitch(), 20.0f), CB::Player::Head.GetYaw(), CB::Player::Head.GetRoll());
            CB::Player::Camera.Rotate(CurveAngle(CB::Player::Head.GetPitch() + 40.0f, CB::Player::Camera.GetPitch(), 40.0f), CB::Player::Camera.GetYaw(), CB::Player::Camera.GetRoll());
        }
        CB::Player::HeadDropSpeed = CB::Player::HeadDropSpeed - 0.002f * FPSFactor;
        return true;
    }

    // FLIPPED CAMERA
    if (flippedcamera == true) {
        Player::Camera.Rotate(Player::Head.GetPitch(), Player::Head.GetYaw(), Player::Head.GetRoll() + 180);
        return true;
    }
    return false;
}
