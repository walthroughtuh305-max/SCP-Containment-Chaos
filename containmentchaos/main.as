using namespace CB;
using namespace B3D;

// EVENTS
bool dooropenevent;
bool flippedcamera = false;
bool lightsout = false;

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
    TimerIcon = LoadImage("GFX\\TimerIcon.png", 1.0);
    TimerMeter = LoadImage("GFX\\TimerMeter.png", 1.0);
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

//int HUDStartX, HUDEndX, HUDStartY, HUDEndY;

void Hook_Update() {
    //if (GraphicsWidth > GraphicsHeight) {
    //    HUDStartY = 0; HUDEndY = GraphicsHeight;
    //    HUDStartX = Options::HUDOffsetScale * GraphicsWidth / 2;
    //    HUDEndX = GraphicsWidth - HUDStartX;
    //} else if (GraphicsWidth < GraphicsHeight) {
    //    HUDStartX = 0; HUDEndX = GraphicsWidth;
    //    HUDStartY = Options::HUDOffsetScale * GraphicsHeight / 2;
    //    HUDEndY = GraphicsHeight - HUDStartY;
    //}
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

void Hook_ChaosEvent(int randomevent) {
    string eventname;
    int eventchance;
    if (randomevent == 1) {
        if (CB::Difficulty::Current.Name == "Safe") eventchance = Rand(1, 30);
        if (CB::Difficulty::Current.Name == "Euclid") eventchance = Rand(1, 40);
        if (CB::Difficulty::Current.Name == "Keter") eventchance = 0;
        if (eventchance == 1) {
            eventname = "Spawn 096";
            NPC::Create(NPC::Type::SCP096, Player::Collider.GetX(true), Player::Collider.GetY(true), Player::Collider.GetZ(true));
        } else if (eventchance != 1) Hook_ChaosEvent(Rand(RandStart, RandEnd));
    }
    if (randomevent == 2) {
        eventchance = Rand(1, 1);
        if (eventchance == 1) {
            eventname = "Fake death";
            FakeDeathAnim = Rand(0, 1);
            StartTimer(randomevent, 300);
        } else if (eventchance != 1) Hook_ChaosEvent(Rand(RandStart, RandEnd));
    }
    if (randomevent == 3) {
        eventname = "Australia";
        flippedcamera = true;
        StartTimer(randomevent, 3600);
    }
    if (randomevent == 4) {
        eventchance = Rand(1, 3);
        if (eventchance == 1) {
            eventname = "Inverted controls";
            CB::Options::InvertMouse = true;
        } else if (eventchance != 1) Hook_ChaosEvent(Rand(RandStart, RandEnd));
    }
    if (randomevent == 5) {
        eventname = "Lights Out";
        lightsout = true;
        StartTimer(randomevent, 1800);
    }
    if (randomevent == 18) {
        eventname = "Open every door the player is closest to";
        dooropenevent = true;
        StartTimer(randomevent, 900);
    }
}

void OnEventTimerComplete(int id) {
    if (id == 2) {
        FakeDeathAnim = -1;
    }
    if (id == 5) {
        lightsout = true;
    }
    if (id == 18) {
        dooropenevent = false;
    }
}

bool Hook_MouseLook() {
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
