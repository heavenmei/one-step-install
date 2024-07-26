import os
import dotenv
import schedule
import time
from time import sleep

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.common.exceptions import NoSuchElementException

dotenv.load_dotenv()
user_name = os.getenv("ECNU_USERNAME")
pwd = os.getenv("ECNU_PASSWORD")
ecnu_url = "https://login.ecnu.edu.cn/"


def login_web():
    driver = webdriver.Chrome()
    driver.set_window_position(20, 40)
    driver.set_window_size(1100, 1000)

    driver.get(ecnu_url)

    # mask
    try:
        confirmBtn = driver.find_element(
            by="css selector", value=".control .btn-confirm"
        )
        if confirmBtn.is_displayed():
            confirmBtn.click()
    except NoSuchElementException:
        print("confirm button Element not found")

    # login button
    try:
        loginBtn = driver.find_element(By.ID, "login-account")
        if loginBtn.is_displayed():
            driver.find_element(By.ID, "username").send_keys(user_name)
            driver.find_element(By.ID, "password").send_keys(pwd)
            loginBtn.click()
    except NoSuchElementException:
        print("login button Element not found")

    driver.quit()


def sche_run():
    schedule.clear()

    # schedule.every(10).seconds.do(login_web)

    schedule.every().day.at("8:00").do(login_web)
    # schedule.every().day.at("10:00").do(login_web)
    # schedule.every().day.at("14:00").do(login_web)
    # schedule.every().day.at("16:00").do(login_web)
    # schedule.every().day.at("18:00").do(login_web)
    # schedule.every().day.at("20:00").do(login_web)

    # 设置定时任务
    # schedule.every(10).minutes.do(job)  # 每隔 10 分钟运行一次 job 函数
    # schedule.every().hour.do(job)  # 每隔 1 小时运行一次 job 函数
    # schedule.every().day.at("10:30").do(job)  # 每天在 10:30 时间点运行 job 函数
    # schedule.every().monday.do(job)  # 每周一 运行一次 job 函数
    # schedule.every().wednesday.at("13:15").do(job)  # 每周三 13：15 时间点运行 job 函数
    # schedule.every().minute.at(":17").do(job)  # 每分钟的 17 秒时间点运行 job 函数

    while True:
        schedule.run_pending()  # 运行所有可以运行的任务
        time.sleep(1)


if __name__ == "__main__":

    sche_run()
