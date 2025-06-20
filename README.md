# AutoBot Email Simulator

Yeh ek advanced Flutter application hai jo ek phone mockup ke andar email bhejne ki prakriya ko automate aur simulate karta hai. Yeh project command-driven automation ka ek behtareen udaharan hai, jismein realistic, human-like behavior, jaise ki typing delays, random scrolling, aur visual effects (blur, animated outlines, toast messages) shamil hain.

Yeh application un developers ke liye ek shandar starting point hai jo Flutter mein complex UI interactions aur automation sequence banana sikhna chahte hain.

---

## Mukhya Visheshtayein (Key Features)

- **Realistic Phone Mockup:** Ek poora phone interface, status bar, app grid, aur notification drawer ke saath.
- **Command-Driven Automation:** Right-side tool drawer se command dekar automation shuru karein.
- **Advanced Email Simulation:** Ek text file se content uthakar email likhne aur bhejne ka poora process simulate karta hai.
- **Human-like Behavior:** Simulation mein insaani tarah ke random delays, scroll speed, aur typing ki gati shaamil hai.
- **Dynamic Visual Feedback:**
    - **Animated Outlines:** Jab bhi bot kisi button ya icon par click karta hai, us par ek sundar, animated outline dikhai deti hai.
    - **Blur Effects:** Screen ke zaroori hisson ko blur karke user ka dhyan aakarshit kiya jaata hai.
    - **Toast Messages:** Real-time status updates ke liye Gmail jaise toast notifications.

---

## Email Simulation Kaise Kaam Karta Hai?

Is application ka sabse powerful feature email simulation hai. Yeh `assets/email/email_template.txt` file ka istemal karke email likhta aur bhejta hai. Simulation shuru karne ke liye neeche diye gaye steps follow karein:

### Command Kaise Dein?

1.  Application ke right side mein bane **Tool Drawer** ko kholein.
2.  Command input box mein `email_template.txt` type karein.
3.  **Run Commands** button par click karein.

### Simulation Ke Steps

Command dene ke baad, AutoBot neeche diye gaye kaaryon ko ek-ek karke, ek insaan ki tarah anjaam dega:

1.  **Random Scrolling (Insaniyat ka Touch):**
    - Simulation shuru hote hi, bot pehle 8 se 20 second tak phone ki home screen par upar-neeche scroll karega, jaise ek aam user karta hai.

2.  **Gmail App Kholna:**
    - Scrolling ke baad, bot "Gmail" app ke icon ko dhundhega aur us par click karke app kholega. App icon par click karte samay ek outline bhi dikhegi.

3.  **Naya Email Compose Karna:**
    - Gmail app khulne ke baad, bot "Compose" button par click karega. Is par bhi ek outline dikhegi.

4.  **Email Likhna (Auto-Typing):**
    - Compose screen khulte hi, **"From"** field mein likhi email ID (`thezestget@gmail.com`) turant **blur** ho jayegi.
    - Bot 7 se 10 second tak intezaar karega.
    - Iske baad, bot `email_template.txt` se **Subject** uthakar use dheere-dheere type karega.
    - Subject poora hone ke baad, bot 5 second ka pause lega.
    - Fir, bot email ka poora **Body** content, line-by-line, type karega. Har nayi line likhne se pehle bot **2 se 4 second** ka random pause lega.

5.  **Recipient Ka Email Add Karna:**
    - Email body poori hone ke baad, **"To"** field **blur** ho jayegi.
    - Bot is field mein `demo@gmail.com` type karega. Dono (From aur To) fields ab blur rahenge.

6.  **Email Bhejna (Sending):**
    - Saari typing poori hone ke baad, "Send" icon active ho jayega.
    - Bot **5 second** tak intezaar karega.
    - Iske baad, "Send" icon par **5 second** ke liye ek sundar, animated outline dikhegi.
    - Fir bot "Send" icon par click karega.

7.  **Antim Steps (Final Actions):**
    - Email "send" hote hi, app aapko wapas primary email list wali screen par le aayega.
    - Screen ke neeche ek toast message dikhega: **"Sending email..."**.
    - Bot is screen par 5 second tak rukega.
    - Aakhir mein, bot wapas **home screen** par jayega.

---

## Getting Started

Yeh ek standard Flutter project hai. Ise run karne ke liye:

1.  Project ko clone karein:
    ```bash
    git clone <repository-url>
    ```
2.  Project directory mein jaayein:
    ```bash
    cd autobotv2email
    ```
3.  Dependencies install karein:
    ```bash
    flutter pub get
    ```
4.  Application ko run karein:
    ```bash
    flutter run
    ```

Flutter aur is project ke baare mein adhik jaankari ke liye, aap Flutter ke [official documentation](https://docs.flutter.dev/) ko dekh sakte hain.
