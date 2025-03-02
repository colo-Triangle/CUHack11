import subprocess

#initialize
subprocess.run("fablo-target/fabric-docker.sh reset", shell=True)

#add data

data = '{\\"name\\":\\"Alice Smith\\",\\"age\\":\\"28\\",\\"condition\\":\\"Diabetes\\",\\"medicalHistory\\":{\\"diagnoses\\":[\\"Type 1 Diabetes\\"],\\"medications\\":[\\"Insulin\\"],\\"lastVisit\\":\\"2024-10-15\\"},\\"emergencyContact\\":{\\"name\\":\\"Bob Smith\\",\\"phone\\":\\"555-1234\\"}}'
patient_id = "P1004"
def add_data(data: str, patient_id: str):
    res = "fablo chaincode invoke peer0.doctor.healthcare.com health-channel patientcc"
    res += ' \'{"Args":["AddPatientJson", ' + f'"{patient_id}", "' + data + '"]}\''
    print(res)
    subprocess.run(res, shell=True)

def get_data(patient_id: str):
    res = "fablo chaincode invoke peer0.doctor.healthcare.com health-channel patientcc '{\"Args\":[\"GetPatient\", \"" + patient_id + "\"]}' >> output.txt"
    subprocess.run(res, shell=True)
