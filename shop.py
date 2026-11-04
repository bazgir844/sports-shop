import tkinter as tk
from tkinter import ttk, messagebox
import pyodbc

def connect_db():
    """اتصال به SQL Server"""
    drivers = [
        "ODBC Driver 17 for SQL Server",
        "ODBC Driver 18 for SQL Server",
        "SQL Server Native Client 11.0",
        "ODBC Driver 13 for SQL Server"
    ]
    servers = [
        r"DESKTOP-32MT905\TEST",
        r".\TEST",
        r"localhost\TEST",
        r"localhost",
        r"."
    ]
    
    for driver in drivers:
        for server in servers:
            try:
                conn = pyodbc.connect(
                    f"DRIVER={{{driver}}};"
                    f"SERVER={server};"
                    f"DATABASE=SportsShop;"
                    f"Trusted_Connection=yes;"
                    f"TrustServerCertificate=yes;",
                    timeout=3
                )
                if conn:
                    return conn
            except:
                continue
    return None

def show_products():
    """نمایش لیست کالاها در جدول با ترتیب کاملاً صحیح ستون‌ها"""
    for row in tree.get_children():
        tree.delete(row)
    
    conn = connect_db()
    if conn:
        try:
            cursor = conn.cursor()
            # ترتیب ستون‌ها: ID, نام کالا, قیمت, موجودی
            cursor.execute("SELECT ProductID, ProductName, Price, Stock FROM Products")
            for row in cursor.fetchall():
                tree.insert("", "end", values=row)
            conn.close()
        except Exception as e:
            messagebox.showerror("خطا", f"خطا در خواندن اطلاعات جدول:\n{e}")
    else:
        messagebox.showerror("خطا", "اتصال به پایگاه داده برقرار نشد!")

# --- ساخت ظاهر برنامه (GUI) ---
root = tk.Tk()
root.title("فروشگاه لوازم ورزشی عاطفه")
root.geometry("700x500")

notebook = ttk.Notebook(root)
notebook.pack(pady=10, expand=True, fill='both')

# تب مدیریت محصولات
tab1 = ttk.Frame(notebook)
notebook.add(tab1, text=" کالاها ")

# ترتیب دقیق سرستون‌ها
columns = ("ID", "نام کالا", "قیمت", "موجودی")
tree = ttk.Treeview(tab1, columns=columns, show="headings")
for col in columns:
    tree.heading(col, text=col)
    tree.column(col, width=120)
tree.pack(pady=20, padx=10, fill='both', expand=True)

btn_refresh = tk.Button(tab1, text="نمایش لیست کالاها", command=show_products, bg="#4CAF50", fg="white", font=("Tahoma", 10))
btn_refresh.pack(pady=10)

tab2 = ttk.Frame(notebook)
notebook.add(tab2, text=" مشتریان ")
tk.Label(tab2, text="این بخش در حال طراحی است...").pack(pady=50)

root.mainloop()