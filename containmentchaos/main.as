using namespace CB;
using namespace B3D;

#include "events.as"

int FakeDeathAnim = -1;

// TIMERS
float safevalueset = 1800;
float safevalue = safevalueset;

float euclidvalueset = 900;
float euclidvalue = euclidvalueset;

float ketervalueset = 600;
float ketervalue = ketervalueset;

float timervalueset, timervalue;

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

void StartTimer(int id, float duration) {
    etimer newtimer(id, duration);
    activeetimers.InsertLast(@newtimer);
}

void Hook_Update() {
    if (Menu::IsMainMenuOpen) return;
    if (CB::Difficulty::Current.Name == "Safe" && Menu::IsAnyOpen() == false) {
        timervalueset = safevalueset;
        timervalue = safevalue;
        if (safevalue > 0) {
            safevalue = safevalue - FPSFactor;
        } 
        if (safevalue <= 0) {
            buzz.Play();
            Hook_ChaosEvent(Rand(RandStart, RandEnd));
            safevalue = safevalueset;
        }
    } else if (CB::Difficulty::Current.Name == "Euclid" && Menu::IsAnyOpen() == false) {
        timervalueset = euclidvalueset;
        timervalue = euclidvalue;
        if (euclidvalue > 0) {
            euclidvalue = euclidvalue - FPSFactor;
        } 
        if (euclidvalue <= 0) {
            buzz.Play();
            Hook_ChaosEvent(Rand(RandStart, RandEnd));
            euclidvalue = euclidvalueset;
        }
    } else if (CB::Difficulty::Current.Name == "Keter" && Menu::IsAnyOpen() == false) {
        timervalueset = ketervalueset;
        timervalue = ketervalue;
        if (ketervalue > 0) {
            ketervalue = ketervalue - FPSFactor;
        } 
        if (ketervalue <= 0) {
            buzz.Play();
            Hook_ChaosEvent(Rand(RandStart, RandEnd));
            ketervalue = ketervalueset;
        }
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
    return false;
}
