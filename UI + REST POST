import tkinter as tk
from tkinter import ttk
from tkcalendar import DateEntry
import datetime
import json
import requests  # For sending the REST request

# Subclass DateEntry to override _show_calendar and then replace the year widget.
class CustomDateEntry(DateEntry):
    def _show_calendar(self):
        # Call the original _show_calendar to open the popup.
        super()._show_calendar()
        # After a short delay, replace the year widget with a combobox.
        self.after(100, lambda: replace_year_widget(self))

def process_field(entry_value):
    """
    Process a comma-separated field:
      - If the user enters 'none' (case-insensitive) or leaves the field empty, return None.
      - Otherwise, split by commas, strip whitespace, and return the list.
    """
    value = entry_value.strip()
    if value.lower() == "none" or value == "":
        return None
    else:
        items = [item.strip() for item in value.split(",") if item.strip() and item.strip().lower() != "none"]
        return items if items else None

def update_year(cal, new_year):
    try:
        new_year = int(new_year)
        # Update the calendar's internal year and refresh the display.
        cal._year = new_year
        cal._update_calendar()
    except Exception as e:
        print("Error updating year:", e)

def replace_year_widget(date_entry):
    """
    Access the popup calendar widget from the DateEntry and replace its year spinbox
    with a Combobox for direct year selection.
    """
    try:
        cal = date_entry._top_cal  # Access the popup calendar widget.
    except AttributeError:
        return  # If the calendar isn't available, exit.
    
    cal.update_idletasks()
    header = getattr(cal, "_header", None)
    if not header:
        return

    # Look for the Spinbox widget in the header (assumed to be the year widget).
    for child in header.winfo_children():
        if child.winfo_class() == 'Spinbox':
            grid_info = child.grid_info()
            child.destroy()  # Remove the spinbox.
            current_year = datetime.date.today().year
            years = list(range(1900, current_year + 1))
            # Create a Combobox with the year range.
            year_cb = ttk.Combobox(header, values=years, width=5)
            year_cb.set(cal._year)
            year_cb.grid(row=grid_info.get("row", 0),
                         column=grid_info.get("column", 0),
                         padx=grid_info.get("padx", 0),
                         pady=grid_info.get("pady", 0))
            # When a new year is selected, update the calendar.
            year_cb.bind("<<ComboboxSelected>>", lambda event: update_year(cal, year_cb.get()))
            break

def show_confirmation(responses):
    confirmation_window = tk.Toplevel(root)
    confirmation_window.title("Confirm Your Information")
    
    style = ttk.Style(confirmation_window)
    style.theme_use('clam')
    style.configure("Blue.TFrame", background="#e6f0ff")
    style.configure("Blue.TLabel", background="#e6f0ff", font=("Arial", 10))
    style.configure("Blue.TButton", font=("Arial", 10))
    
    main_frame = ttk.Frame(confirmation_window, padding="20", style="Blue.TFrame")
    main_frame.grid(row=0, column=0, sticky="nsew")
    
    header_label = ttk.Label(main_frame, text="Please Confirm Your Information", 
                             style="Blue.TLabel", font=("Arial", 14, "bold"))
    header_label.grid(row=0, column=0, columnspan=2, pady=(0, 10))
    
    fields = [
        ("Name", responses.get("name", "")),
        ("DOB (MM/DD/YYYY)", responses.get("dob", "")),
        ("Sex", ", ".join(responses.get("sex", [])) if responses.get("sex") else "None"),
        ("Height", f'{responses.get("height", {}).get("feet", "")} feet {responses.get("height", {}).get("inches", "")} inches'),
        ("Weight (lbs)", responses.get("weight", "")),
        ("Medications", ", ".join(responses.get("medications", [])) if responses.get("medications") else "None"),
        ("Allergies", ", ".join(responses.get("allergies", [])) if responses.get("allergies") else "None"),
        ("Preexisting Conditions", ", ".join(responses.get("preexisting_conditions", [])) if responses.get("preexisting_conditions") else "None"),
    ]
    
    for i, (label_text, value_text) in enumerate(fields, start=1):
        lbl = ttk.Label(main_frame, text=label_text+":", style="Blue.TLabel", anchor="e", width=20)
        lbl.grid(row=i, column=0, sticky="e", padx=5, pady=5)
        val = ttk.Label(main_frame, text=value_text, style="Blue.TLabel", anchor="w", width=40)
        val.grid(row=i, column=1, sticky="w", padx=5, pady=5)
    
    button_frame = ttk.Frame(main_frame, style="Blue.TFrame")
    button_frame.grid(row=len(fields) + 1, column=0, columnspan=2, pady=10)
    
    confirm_button = ttk.Button(button_frame, text="Confirm",
                                command=lambda: confirm_response(confirmation_window, responses))
    confirm_button.pack(side="left", padx=10)
    
    edit_button = ttk.Button(button_frame, text="Edit",
                             command=confirmation_window.destroy)
    edit_button.pack(side="right", padx=10)

def confirm_response(confirmation_window, responses):
    # Save the responses to a JSON file.
    with open("responses.json", "w") as json_file:
        json.dump(responses, json_file, indent=4)
    
    # Close the confirmation and main windows.
    confirmation_window.destroy()
    root.destroy()
    
    # Automatically send the JSON to the predetermined IP.
    ip_address = "http://97.228.182.15"  # Using HTTP scheme by default.
    status, message = send_rest_request(ip_address, responses)
    
    # Show the result in a new window.
    result_window = tk.Tk()
    result_window.title("REST Request Result")
    
    style = ttk.Style(result_window)
    style.theme_use('clam')
    style.configure("Blue.TFrame", background="#e6f0ff")
    style.configure("Blue.TLabel", background="#e6f0ff", font=("Arial", 10))
    style.configure("Blue.TButton", font=("Arial", 10))
    
    frame = ttk.Frame(result_window, padding="20", style="Blue.TFrame")
    frame.pack(expand=True, fill="both")
    
    result_label = ttk.Label(frame, text=message, style="Blue.TLabel", font=("Arial", 12, "bold"))
    result_label.pack(pady=10)
    
    exit_button = ttk.Button(frame, text="Exit", style="Blue.TButton", command=result_window.destroy)
    exit_button.pack(pady=10)
    
    result_window.mainloop()

def send_rest_request(ip_address, responses):
    """
    Sends a POST request to the specified IP/URL with the responses as JSON.
    Returns a tuple: (status, message)
    """
    try:
        response = requests.post(ip_address, json=responses)
        if response.ok:
            return True, "Request successful!"
        else:
            return False, f"Request failed with status code: {response.status_code}"
    except Exception as e:
        return False, f"Error sending request: {str(e)}"

def submit():
    responses = {}
    responses["name"] = name_entry.get().strip()
    responses["dob"] = dob_entry.get()  # Already in MM/DD/YYYY format
    sex = []
    if male_var.get():
        sex.append("Male")
    if female_var.get():
        sex.append("Female")
    responses["sex"] = sex if sex else None
    responses["height"] = {
        "feet": feet_entry.get().strip(),
        "inches": inches_entry.get().strip()
    }
    responses["weight"] = weight_entry.get().strip()
    responses["medications"] = process_field(medications_entry.get())
    responses["allergies"] = process_field(allergies_entry.get())
    responses["preexisting_conditions"] = process_field(preexisting_conditions_entry.get())
    
    show_confirmation(responses)

# Main window (User Information Form)
root = tk.Tk()
root.title("User Information Form")

style = ttk.Style(root)
style.theme_use('clam')
style.configure("Blue.TFrame", background="#e6f0ff")
style.configure("Blue.TLabel", background="#e6f0ff", font=("Arial", 10))
style.configure("Blue.TButton", font=("Arial", 10))
root.configure(background="#e6f0ff")

main_frame = ttk.Frame(root, padding="20", style="Blue.TFrame")
main_frame.pack(expand=True, fill="both")

name_label = ttk.Label(main_frame, text="Name:", style="Blue.TLabel")
name_label.grid(row=0, column=0, sticky="e", padx=5, pady=5)
name_entry = ttk.Entry(main_frame, width=30)
name_entry.grid(row=0, column=1, padx=5, pady=5)

dob_label = ttk.Label(main_frame, text="DOB (MM/DD/YYYY):", style="Blue.TLabel")
dob_label.grid(row=1, column=0, sticky="e", padx=5, pady=5)
# Use CustomDateEntry instead of the standard DateEntry.
dob_entry = CustomDateEntry(main_frame, width=27, date_pattern='mm/dd/yyyy',
                      mindate=datetime.date(1900, 1, 1),
                      maxdate=datetime.date.today(),
                      showothermonthdays=False)
dob_entry.grid(row=1, column=1, padx=5, pady=5)

sex_label = ttk.Label(main_frame, text="Sex:", style="Blue.TLabel")
sex_label.grid(row=2, column=0, sticky="e", padx=5, pady=5)
sex_frame = ttk.Frame(main_frame, style="Blue.TFrame")
sex_frame.grid(row=2, column=1, sticky="w", padx=5, pady=5)
male_var = tk.BooleanVar()
female_var = tk.BooleanVar()
male_check = ttk.Checkbutton(sex_frame, text="Male", variable=male_var)
male_check.pack(side="left", padx=5)
female_check = ttk.Checkbutton(sex_frame, text="Female", variable=female_var)
female_check.pack(side="left", padx=5)

height_label = ttk.Label(main_frame, text="Height:", style="Blue.TLabel")
height_label.grid(row=3, column=0, sticky="e", padx=5, pady=5)
height_frame = ttk.Frame(main_frame, style="Blue.TFrame")
height_frame.grid(row=3, column=1, sticky="w", padx=5, pady=5)
feet_label = ttk.Label(height_frame, text="Feet:", style="Blue.TLabel")
feet_label.pack(side="left")
feet_entry = ttk.Entry(height_frame, width=5)
feet_entry.pack(side="left", padx=5)
inches_label = ttk.Label(height_frame, text="Inches:", style="Blue.TLabel")
inches_label.pack(side="left")
inches_entry = ttk.Entry(height_frame, width=5)
inches_entry.pack(side="left", padx=5)

weight_label = ttk.Label(main_frame, text="Weight (lbs):", style="Blue.TLabel")
weight_label.grid(row=4, column=0, sticky="e", padx=5, pady=5)
weight_entry = ttk.Entry(main_frame, width=30)
weight_entry.grid(row=4, column=1, padx=5, pady=5)

medications_label = ttk.Label(main_frame, text='Medications (comma separated, enter "none" if not applicable):', style="Blue.TLabel")
medications_label.grid(row=5, column=0, sticky="e", padx=5, pady=5)
medications_entry = ttk.Entry(main_frame, width=30)
medications_entry.grid(row=5, column=1, padx=5, pady=5)

allergies_label = ttk.Label(main_frame, text='Allergies (comma separated, enter "none" if not applicable):', style="Blue.TLabel")
allergies_label.grid(row=6, column=0, sticky="e", padx=5, pady=5)
allergies_entry = ttk.Entry(main_frame, width=30)
allergies_entry.grid(row=6, column=1, padx=5, pady=5)

preexisting_conditions_label = ttk.Label(main_frame, text='Preexisting Conditions (comma separated, enter "none" if not applicable):', style="Blue.TLabel")
preexisting_conditions_label.grid(row=7, column=0, sticky="e", padx=5, pady=5)
preexisting_conditions_entry = ttk.Entry(main_frame, width=30)
preexisting_conditions_entry.grid(row=7, column=1, padx=5, pady=5)

submit_button = ttk.Button(main_frame, text="Submit", style="Blue.TButton", command=submit)
submit_button.grid(row=8, column=1, pady=10)

root.mainloop()
