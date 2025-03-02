package main

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// PatientChaincode implements the fabric contract interface
type PatientChaincode struct {
	contractapi.Contract
}

// Patient represents the basic patient record structure
type Patient struct {
	ID        string `json:"id"`
	Name      string `json:"name"`
	Age       string `json:"age"`
	Condition string `json:"condition"`
	DoctorID  string `json:"doctorId"`
}

// InitLedger initializes the ledger with no initial data
func (pc *PatientChaincode) InitLedger(ctx contractapi.TransactionContextInterface) error {
	return nil
}

// AddPatient adds a new patient record with structured fields
func (pc *PatientChaincode) AddPatient(ctx contractapi.TransactionContextInterface,
	id string,
	name string,
	age string,
	condition string) error {

	clientOrgID, err := ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return fmt.Errorf("failed to get client organization ID: %v", err)
	}

	if clientOrgID != "DoctorMSP" {
		return fmt.Errorf("only Doctor organization can add patient records")
	}

	patientBytes, err := ctx.GetStub().GetState(id)
	if err != nil {
		return fmt.Errorf("failed to read from world state: %v", err)
	}
	if patientBytes != nil {
		return fmt.Errorf("patient with ID %s already exists", id)
	}

	doctorID, err := ctx.GetClientIdentity().GetID()
	if err != nil {
		return fmt.Errorf("failed to get doctor ID: %v", err)
	}

	patient := Patient{
		ID:        id,
		Name:      name,
		Age:       age,
		Condition: condition,
		DoctorID:  doctorID,
	}

	patientJSON, err := json.Marshal(patient)
	if err != nil {
		return fmt.Errorf("failed to marshal patient to JSON: %v", err)
	}

	err = ctx.GetStub().PutState(id, patientJSON)
	if err != nil {
		return fmt.Errorf("failed to put patient to world state: %v", err)
	}

	return nil
}

// AddPatientJson adds a patient record from a JSON string
func (pc *PatientChaincode) AddPatientJson(ctx contractapi.TransactionContextInterface,
	id string,
	jsonString string) error {

	clientOrgID, err := ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return fmt.Errorf("failed to get client organization ID: %v", err)
	}

	if clientOrgID != "DoctorMSP" {
		return fmt.Errorf("only Doctor organization can add patient records")
	}

	patientBytes, err := ctx.GetStub().GetState(id)
	if err != nil {
		return fmt.Errorf("failed to read from world state: %v", err)
	}
	if patientBytes != nil {
		return fmt.Errorf("patient with ID %s already exists", id)
	}

	// Parse the JSON string into a generic map
	var patientData map[string]interface{}
	err = json.Unmarshal([]byte(jsonString), &patientData)
	if err != nil {
		return fmt.Errorf("failed to parse JSON string: %v", err)
	}

	// Add ID and doctorID to the patient data
	doctorID, err := ctx.GetClientIdentity().GetID()
	if err != nil {
		return fmt.Errorf("failed to get doctor ID: %v", err)
	}
	patientData["id"] = id
	patientData["doctorId"] = doctorID

	// Marshal back to JSON for storage
	updatedPatientJSON, err := json.Marshal(patientData)
	if err != nil {
		return fmt.Errorf("failed to marshal updated patient JSON: %v", err)
	}

	err = ctx.GetStub().PutState(id, updatedPatientJSON)
	if err != nil {
		return fmt.Errorf("failed to put patient to world state: %v", err)
	}

	return nil
}

// GetPatient retrieves a patient record from the ledger
func (pc *PatientChaincode) GetPatient(ctx contractapi.TransactionContextInterface, id string) (string, error) {
	clientOrgID, err := ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return "", fmt.Errorf("failed to get client organization ID: %v", err)
	}

	if clientOrgID != "DoctorMSP" && clientOrgID != "PatientMSP" {
		return "", fmt.Errorf("only Doctor or Patient organizations can read patient records")
	}

	patientBytes, err := ctx.GetStub().GetState(id)
	if err != nil {
		return "", fmt.Errorf("failed to read from world state: %v", err)
	}
	if patientBytes == nil {
		return "", fmt.Errorf("patient with ID %s does not exist", id)
	}

	return string(patientBytes), nil
}

func main() {
	chaincode, err := contractapi.NewChaincode(&PatientChaincode{})
	if err != nil {
		fmt.Printf("Error creating patient chaincode: %v\n", err)
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting patient chaincode: %v\n", err)
	}
}
