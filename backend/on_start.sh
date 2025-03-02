curl --request POST \
  --url http://localhost:8000/user/enroll \
  --header 'Authorization: Bearer ' \
  --data '{"id": "Admin", "secret": "adminpw"}'